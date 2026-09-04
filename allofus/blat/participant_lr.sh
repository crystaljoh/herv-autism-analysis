check_long_read_bam_exists ()
{
    local participant_id=$1
    read -r hap1 hap2 <<< $(awk  -v participant_id=${participant_id} '{ if (($1 == participant_id))  {print $8, $14 }}' ~/workspace/srwgs/v9/wgs/long_read/manifest.tsv)
    if [[ $hap1 = "" || $hap1 = "NA" ]]
    then
        echo "lrWGS not found for participant $pariticipant_id"
        exit 1
    fi
    hap[1]=${hap1/gs:\/\/vwb-aou-datasets-controlled/\/home\/jupyter\/workspace\/srwgs}
    hap[2]=${hap2/gs:\/\/vwb-aou-datasets-controlled/\/home\/jupyter\/workspace\/srwgs}
    if [[ ! -f ${hap[1]} ]]
    then
        echo " Did not find ${hap[1]}"
        exit 1
    fi
}

check_cram_exists ()
{
    local participant_id=$1
    if [ ! -f ~/workspace/srwgs/pooled/wgs/cram/v8_base/wgs_${participant_id}.cram ]
    then
        echo  "No short read WGS data found in cdrv8 for $participant_id"
        exit 1
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
        if [ $long_reads = 0 ]
        then
            check_cram_exists $participant_id
            echo "Converting cram to bam for $participant_id $chromosome"
    	    samtools view -b --threads 10 -o data/bam_${participant_id}_${chromosome}.bam -T hg38/Homo_sapiens_assembly38.fasta ~/workspace/srwgs/pooled/wgs/cram/v8_base/wgs_${participant_id}.cram $chromosome
            echo "Phasing  $participant_id $chromosome"
    	    samtools phase -b data/phased_${participant_id}_${chromosome} data/bam_${participant_id}_${chromosome}.bam > data/samphase_${participant_id}_${chromosome}.log
        fi
	    if [ $long_reads = 1 ]
        then
            process_phase $participant_id $chromosome 2
        else
            process_phase $participant_id $chromosome 0 
        fi
	    process_phase $participant_id $chromosome 1
	    wait
        if [ $long_reads = 0 ]
        then
     	    delete_files data/samphase_${participant_id}_${chromosome}.log
    	    delete_files data/bam_${participant_id}_${chromosome}.bam*
    	    delete_files data/phased_${participant_id}_${chromosome}*
        fi
	  fi
    fi
	if [ $long_reads = 1 ]
    then
        blat_phase $participant_id $chromosome 2 
    else
        blat_phase $participant_id $chromosome 0 
    fi    
	if [ ! $participant_id = "ref" ]
	then
	    blat_phase $participant_id $chromosome 1 
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
        if [ $long_reads = 0 ]
        then
            check_cram_exists $participant_id
            echo "Converting cram to bam for $participant_id $chromosome"
    	    samtools view -b --threads 10 -o data/phased_${participant_id}_${chromosome}.${haplotype}.bam -T hg38/Homo_sapiens_assembly38.fasta ~/workspace/srwgs/pooled/wgs/cram/v8_base/wgs_${participant_id}.cram $chromosome
        fi
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
        if [ $long_reads = 1 ]
        then
            check_long_read_bam_exists $participant_id
            if [[ ${haplotype} = "1" ]]
            then
                bam_file=${hap[1]}
            else
                bam_file=${hap[2]}
            fi
            if [ $chromosome = "blah" ]
            then
                # experiments to narrow down the region in chr1 with the memory problem
                # limit virtual memory size
                ulimit -v 10000000
                # disable core dumps
                ulimit -c 0
                # chr1 has to be done in multiple parts otherwise consensus OOMs
                samtools consensus -f fasta -X hifi -aa --show-del yes --show-ins yes --mark-ins -r ${chromosome}:143100001-143150000 -o data/fasta_${participant_id}_${chromosome}_${haplotype}.indel.fa ${bam_file}
                if [ $? != 0 ]; then echolog "Consensus building failed for ${participant_id} ${chromosome} ${haplotype}"; return 1; fi
                samtools consensus -T hg38/${chromosome}.fa -f fasta -X hifi -aa --show-del yes --show-ins yes --mark-ins -r ${chromosome}:143150001-143200000 ${bam_file} >> data/fasta_${participant_id}_${chromosome}_${haplotype}.indel.fa 
                if [ $? != 0 ]; then echolog "Consensus building failed for ${participant_id} ${chromosome} ${haplotype}"; return 1; fi
                samtools consensus -f fasta -X hifi -aa --show-del yes --show-ins yes --mark-ins -r ${chromosome}:143000001-145000000 ${bam_file} >> data/fasta_${participant_id}_${chromosome}_${haplotype}.indel.fa 
                if [ $? != 0 ]; then echolog "Consensus building failed for ${participant_id} ${chromosome} ${haplotype}"; return 1; fi
            else
                # limit virtual memory size
                ulimit -v 10000000
                # disable core dumps
                ulimit -c 0
                # show insertions and deletions for creating offsets file
                # filter out supplementary alignments because they cause excessive memory use - TBD if this will cause problems with the consensus
               samtools consensus -f fasta -X hifi -aa --excl-flags SUPPLEMENTARY --show-del yes --show-ins yes --mark-ins -r ${chromosome} -o data/fasta_${participant_id}_${chromosome}_${haplotype}.indel.fa ${bam_file}
                if [ $? != 0 ]; then echolog "Consensus building failed for ${participant_id} ${chromosome} ${haplotype}"; return 1; fi
            fi
            # create offsets file and strip deletions and insertion markings from fasta
            awk -v offsets_file="data/fasta_${participant_id}_${chromosome}_${haplotype}_offsets.txt" -f calculate_offsets.awk data/fasta_${participant_id}_${chromosome}_${haplotype}.indel.fa > data/fasta_${participant_id}_${chromosome}_${haplotype}.fa
       else
        	samtools index data/phased_${participant_id}_${chromosome}.${haplotype}.bam
            echo "Creating consensus assembly for $participant_id $chromosome"
        	samtools consensus -a -C 0 -T hg38/${chromosome}.fa -r ${chromosome} -f fasta data/phased_${participant_id}_${chromosome}.${haplotype}.bam > data/fasta_${participant_id}_${chromosome}_${haplotype}.fa
        fi
	  ./faToTwoBit data/fasta_${participant_id}_${chromosome}_${haplotype}.fa  data/fasta_${participant_id}_${chromosome}_${haplotype}.2bit
    if [ $delete_fasta = 1 ]
    then
      delete_files data/fasta_${participant_id}_${chromosome}_${haplotype}.*fa
    fi
fi
}

blat_herv ()
{
	local participant_id=$1
	local chromosome=$2
	local haplotype=$3
	local herv=$4
	local unique_suffix=$1_$2_$3_$4
    local ref_output_dir=output/ref
    local ref_output_file=ref_${chromosome}_${herv}.psl
	local target_file
	local output_file
    local output_dir
	if [ $participant_id = "ref" ]
	then
	    target_file=hg38/${chromosome}.2bit
        output_dir=${ref_output_dir}
	    output_file=${output_dir}/$ref_output_file
	else
	    target_file=data/fasta_${participant_id}_${chromosome}_${haplotype}.2bit
        output_dir=output/${participant_id}/${chromosome}
	    output_file=${output_dir}/blat_output_${unique_suffix}.psl
	fi
    mkdir -p ${output_dir}
	if [ ! -f ${target_file} ]; then echo "Skipping blat because ${target_file} missing"; return 1; fi
	if [ $doblat = 1 ]
    then
        ./blat -minIdentity=${minIdentity}  -maxIntron=${maxIntron} ${target_file} hervs/${herv} ${output_file} > /dev/null
    fi
    if [ $participant_id != "ref" ]
	then
    offsets_file="data/fasta_${participant_id}_${chromosome}_${haplotype}_offsets.txt"	    
    awk -v haplotype=${haplotype} -v threshold=${threshold} -v slack=${slack} -f find_matches_with_offsets.awk $offsets_file ${ref_output_dir}/${ref_output_file} ${output_file} | tee -a ${logfile} 
	fi	
}

delete_files ()
{
   rm $*
}

echolog ()
{
  echo $* | tee -a ${logfile}
}

participant_id=$1
male=${male:-1}
threshold=${threshold:=0.9}
slack=${slack:=1000}
minIdentity=${minIdentity:=80}
maxIntron=${maxIntron:=400}
delete_fasta=${delete_fasta:=1}
long_reads=${long_reads:=1}
doblat=${doblat:=1}
logfile="results/mismatches_only_${participant_id}.txt"
echo "long reads ${long_reads}"
mkdir -p data
mkdir -p output
mkdir -p results

if [ ! -d ~/workspace/srwgs ] 
then
    wb resource mount --id=srwgs
fi

if [ $participant_id = "ref" ]
then
  ./get_ref.sh
fi

echolog "Processing participant $participant_id minIdentity ${minIdentity} maxIntron ${maxIntron} threshold ${threshold} slack ${slack}"
echolog "Chromosomes ${chromosomes}"
# Keep this in sync with find_matches.awk if we change the fields we output
echolog "Fields in PSL format output are"
echolog "matches misMatches repMatches nCount queryNumInsert queryBaseInsert targetNumInsert targetBaseInsert strand qName qSize qStart qEnd tName tSize tStart tEnd blockCount haplotype"
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
echo "$participant_id" >> participant_completed
