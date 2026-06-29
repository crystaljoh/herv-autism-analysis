participant_id=$1
chromosome=$2
haplotype=$3
if [ $participant_id = "ref" ]
then
    haplotype=0
fi
find Workplace_${participant_id}_${chromosome}_${haplotype} -name 'Putein*' -print -exec egrep 'Starts at position|For fit to alignment|{ Gene:|MostUsedRow' {} \; | awk -v chromosome=${chromosome} -f ../../merge_lines.awk  | sort -n -k 1,1 > Workplace_${participant_id}_${chromosome}_${haplotype}/genes.txt
if [ $participant_id != "ref" ]
then
    awk  -v slack=${slack:=60000} -f ../../find_matches.awk Workplace_ref_${chromosome}_0/genes.txt Workplace_${participant_id}_${chromosome}_${haplotype}/genes.txt | sort -n -k 2,2 > Workplace_${participant_id}_${chromosome}_${haplotype}/mismatches.txt 
fi
