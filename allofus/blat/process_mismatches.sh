egrep "Insertion|Deletion" results/mismatches_only*  | sort -k 11,11 -k 15,15 -k 17,17n -k 1,1 -k20,20 | uniq | sed -f hervnames.sed | gawk -f group_mismatches.awk > mismatches.txt
