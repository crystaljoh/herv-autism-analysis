participant_id=$1
chromosome=$2
haplotype=$3
if [ $participant_id = "ref" ]
then
    haplotype=0
fi
find Workplace_${participant_id}_${chromosome}_${haplotype} -name 'Putein*' -print -exec egrep 'Starts at position|For fit to alignment|{ Gene:' {} \; | awk -v chromosome=${chromosome} -f ../../merge_lines.awk  | sort -n -k 2 > Workplace_${participant_id}_${chromosome}_${haplotype}/genes.txt