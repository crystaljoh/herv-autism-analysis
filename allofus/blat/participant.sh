process_chromosome ()
{
	local participant_id=$1
	local chromosome=$2
	if [ $generate = 1 ]
	then
	  samtools view -b --threads 10 -o data/bam_${participant_id}_${chromosome}.bam -T hg38/Homo_sapiens_assembly38.fasta data/wgs_${participant_id}.cram $chromosome
	  samtools phase -b data/phased_${participant_id}_${chromosome} data/bam_${participant_id}_${chromosome}.bam > data/samphase_${participant_id}_${chromosome}.log
	fi
	process_phase $participant_id $chromosome 0 &
	process_phase $participant_id $chromosome 1 &
	wait
	if [ $generate = 1 ]
	then
	  delete_files data/samphase_${participant_id}_${chromosome}.log
	  delete_files data/bam_${participant_id}_${chromosome}.bam*
	  delete_files data/phased_${participant_id}_${chromosome}*
	fi
}

process_male_chromosome ()
{
	# for male sex chromosomes, no need to phase
	local participant_id=$1
	local chromosome=$2
	local haplotype=0
	if [ $generate = 1 ]
	then
	  samtools view -b --threads 10 -o data/phased_${participant_id}_${chromosome}.${haplotype}.bam -T hg38/Homo_sapiens_assembly38.fasta data/wgs_${participant_id}.cram $chromosome
	fi
	process_phase $participant_id $chromosome $haplotype
	if [ $generate = 1 ]
	then
	  delete_files data/phased_${participant_id}_${chromosome}*
	fi
}

process_phase ()
{
	local participant_id=$1
	local chromosome=$2
	local haplotype=$3
	local unique_suffix=$1_$2_$3
	if [ $generate = 1 ]
	then
	  samtools index --threads 10 data/phased_${participant_id}_${chromosome}.${haplotype}.bam
	  samtools consensus --threads 10 -a -r ${chromosome} -f fasta data/phased_${participant_id}_${chromosome}.${haplotype}.bam > data/fasta_${participant_id}_${chromosome}_${haplotype}.fa
	  ./faToTwoBit data/fasta_${participant_id}_${chromosome}_${haplotype}.fa data/fasta_${participant_id}_${chromosome}_${haplotype}.2bit
	  # Let's not delete the fasta file for now because we want to use it for retroTector etec
      # delete_files data/fasta_${participant_id}_${chromosome}_${haplotype}.fa
	fi
	for herv in $(command ls hervs) ; do
	   blat_herv $participant_id $chromosome $haplotype $herv
	done 
if [ $delete_fasta = 1 ]
	then
      delete_files data/fasta_${participant_id}_${chromosome}_${haplotype}.fa
	  delete_files data/fasta_${participant_id}_${chromosome}_${haplotype}.2bit
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
	echo ./blat -minIdentity=${minIdentity:=90}  -maxIntron=${maxIntron:=300} ${target_file} hervs/${herv} ${output_file}
	./blat -minIdentity=${minIdentity:=90}  -maxIntron=${maxIntron:=300} ${target_file} hervs/${herv} ${output_file}
        if [ $participant_id != "ref" ]
	then
	    awk -v threshold=${threshold:=0.5} -v slack=${slack:=60000} -f find_matches.awk ${ref_output_file} ${output_file} > output/results_${unique_suffix}.txt 
	fi

	# only alignments that match nearly all the query
        # start in query must be near the start and end in query must be near the end
	# additionally the size of the base gaps in the query must be low
	awk 'NR<6 || ($12 < 11 && $13 > $11 - 11 && $6 < 200 )'  ${output_file} > ${output_file}.awked
	
        # old stuff
	# TODO: identify the best match of all overlapping matches and just report those
	# at the moment many HERVs match any particular one partially
	#awk 'NR<6 || $1 * 10 > $11 * 4.5'  output/blat_output_${unique_suffix}.psl  > output/blat_output_${unique_suffix}.awked
	# ./pslScore output/blat_output_${unique_suffix}.awked  | sort -n -k 2 > output/blat_output_simplified_${unique_suffix}.txt
	#./pslScore output/blat_output_${unique_suffix}.awked  \
	#    | sort -n -k 2 \
	#    | awk -v herv=$herv -v chromosome=$chromosome -v haplotype=$haplotype -v participant=$participant_id '{ print herv, chromosome, participant, haplotype, $0 }' > output/blat_output_simplified_${unique_suffix}.txt
	#echo "Matches for participant $participant_id chromosome $chromosome haplotype $haplotype HERV $herv"
	#wc output/blat_output_simplified_${unique_suffix}.txt
}

delete_files ()
{
   rm $*
}

generate=${generate_fasta:?"must set generate_fasta to 0 or 1"}
if [ $participant_id = "ref" ]
then
  generate=0
fi
delete_fasta=0
participant_id=$1
male=${male:-1}
echo "Processing participant $participant_id"
if [ $generate = 1 ]
then
  gsutil -u $GOOGLE_PROJECT cp gs://vwb-aou-datasets-controlled/pooled/wgs/cram/*/wgs_$participant_id* data
fi
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
if [ $generate = 1 ]
then
  delete_files data/wgs_$participant_id*
fi
echo "$participant_id" >> participant_completed
