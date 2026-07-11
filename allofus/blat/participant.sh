fetch_cram_if_necessary ()
{
    local participant_id=$1
    if [ ! -f data/wgs_${participant_id}.cram ]
    then
      echo "Fetching cram file for $participant_id"
      gsutil -u $GOOGLE_PROJECT cp gs://vwb-aou-datasets-controlled/pooled/wgs/cram/*/wgs_$participant_id* data
    fi
}

process_chromosome ()
{
	local participant_id=$1
	local chromosome=$2
    local haplotype=0
	if [ ! $participant_id = "ref" ]
	then
	  if [ ! -f data/fasta_${participant_id}_${chromosome}_${haplotype}.2bit ]
	  then
        fetch_cram_if_necessary $participant_id
        echo "Converting cram to bam for $participant_id $chromosome"
	    samtools view -b --threads 10 -o data/bam_${participant_id}_${chromosome}.bam -T hg38/Homo_sapiens_assembly38.fasta data/wgs_${participant_id}.cram $chromosome
        echo "Phasing  $participant_id $chromosome"
	    samtools phase -b data/phased_${participant_id}_${chromosome} data/bam_${participant_id}_${chromosome}.bam > data/samphase_${participant_id}_${chromosome}.log
	    process_phase $participant_id $chromosome 0 &
	    process_phase $participant_id $chromosome 1 &
	    wait
	    delete_files data/samphase_${participant_id}_${chromosome}.log
	    delete_files data/bam_${participant_id}_${chromosome}.bam*
	    delete_files data/phased_${participant_id}_${chromosome}*
	  fi
    fi
	blat_phase $participant_id $chromosome 0 &
	if [ ! $participant_id = "ref" ]
	then
	    blat_phase $participant_id $chromosome 1 &
    fi
    wait
}

process_male_chromosome ()
{
	# for male sex chromosomes, no need to phase
	local participant_id=$1
	local chromosome=$2
	local haplotype=0
	if [ ! $participant_id = "ref" ]
	then
	  if [ ! -f data/fasta_${participant_id}_${chromosome}_${haplotype}.2bit ]
	  then
        fetch_cram_if_necessary $participant_id
        echo "Converting cram to bam for $participant_id $chromosome"
	    samtools view -b --threads 10 -o data/phased_${participant_id}_${chromosome}.${haplotype}.bam -T hg38/Homo_sapiens_assembly38.fasta data/wgs_${participant_id}.cram $chromosome
 	    process_phase $participant_id $chromosome $haplotype
	    delete_files data/phased_${participant_id}_${chromosome}*
	  fi
    fi
    blat_phase $participant_id $chromosome 0
}

blat_phase ()
{
	local participant_id=$1
	local chromosome=$2
	local haplotype=$3
	local unique_suffix=$1_$2_$3
	for herv in $(command ls hervs) ; do
	   blat_herv $participant_id $chromosome $haplotype $herv
	done 
}

process_phase ()
{
	local participant_id=$1
	local chromosome=$2
	local haplotype=$3
	local unique_suffix=$1_$2_$3
	if [ ! -f data/fasta_${participant_id}_${chromosome}_${haplotype}.2bit ]
	then
	  samtools index --threads 10 data/phased_${participant_id}_${chromosome}.${haplotype}.bam
      echo "Creating consensus assembly for $participant_id $chromosome"
	  samtools consensus --threads 10 -a -r ${chromosome} -f fasta data/phased_${participant_id}_${chromosome}.${haplotype}.bam > data/fasta_${participant_id}_${chromosome}_${haplotype}.fa
	  ./faToTwoBit data/fasta_${participant_id}_${chromosome}_${haplotype}.fa  data/fasta_${participant_id}_${chromosome}_${haplotype}.2bit
	fi
}

blat_herv ()
{
	local participant_id=$1
	local chromosome=$2
	local haplotype=$3
	local herv=$4
	local unique_suffix=$1_$2_$3_$4
        local ref_output_file=output/ref_${chromosome}_${herv}.psl
	local target_file
	local output_file
	if [ $participant_id = "ref" ]
	then
	    target_file=hg38/${chromosome}.2bit
	    output_file=$ref_output_file
	else
	    target_file=data/fasta_${participant_id}_${chromosome}_${haplotype}.2bit
	    output_file=output/blat_output_${unique_suffix}.psl
	fi
	# echo ./blat -minIdentity=${minIdentity:=90}  -maxIntron=${maxIntron:=300} ${target_file} hervs/${herv} ${output_file}
	./blat -minIdentity=${minIdentity}  -maxIntron=${maxIntron:=300} ${target_file} hervs/${herv} ${output_file} > /dev/null
    if [ $participant_id != "ref" ]
	then
	    awk -v threshold=${threshold} -v slack=${slack} -f find_matches.awk ${ref_output_file} ${output_file} > output/results_${unique_suffix}.txt 
        if [ -s output/results_${unique_suffix}.txt ]
        then
            echo ""
            echo "Possible insertions and/or deletions for participant $participant_id $chromosome $haplotype and herv $herv"
            cat output/results_${unique_suffix}.txt
        else
            rm output/results_${unique_suffix}.txt
        fi
	fi

    # ! we don't seem to be using this at the moment. Review whether it is necessary and if so fix
	# only alignments that match nearly all the query
    # start in query must be near the start and end in query must be near the end
	# additionally the size of the base gaps in the query must be low
	# awk 'NR<6 || ($12 < 11 && $13 > $11 - 11 && $6 < 200 )'  ${output_file} > ${output_file}.awked
	
}

delete_files ()
{
   rm $*
}


delete_fasta=0
participant_id=$1
male=${male:-1}
threshold=${threshold:=0.5}
slack=${slack:=60000}
minIdentity=${minIdentity:=80}

mkdir -p data
mkdir -p output

if [ $participant_id = "ref" ]
then
  ./get_ref.sh
fi

echo "Processing participant $participant_id minIdentity ${minIdentity} threshold ${threshold} slack ${slack}"
# Keep this in sync with find_matches.awk if we change the fields we output
echo "Fields in PSL format output are"
echo "matches mismMtches repMatches nCount queryNumInsert queryBaseInsert targetNumInsert targetBaseInsert strand qName qSize qStart qEnd tName tSize tStart tEnd blockCount"
for chromosome in ${chromosomes:?"must set chromosomes variable"} ; do
   # sex chromosomes must be handled specially for males because they only have one copy so are not phased 
   if [ $male = 1 ] && [ $chromosome = "chrX" ] || [ $chromosome = "chrY" ]
   then
       process_male_chromosome $participant_id $chromosome
   # skip chrY for females
   elif [ $male = 1 ] || [ $chromosome != "chrY" ]  
   then
       process_chromosome $participant_id $chromosome
   fi
done
wait
#if [ $generate = 1 ]
#then
#  delete_files data/wgs_$participant_id*
#fi
echo "$participant_id" >> participant_completed
