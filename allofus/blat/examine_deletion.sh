# commands to examine an apparent deletion
# example line to pass to this script (x are don't care)
# the line is exactly as found in one of the mismatches_only files, with the participant_id added at the fro
# participant_id x x x x x x x x x x x DFAM_accession_number x x x chromosome x ref_start ref_end x par_start haplotype
# 1023419 Deletion  5153 391 0 1 25 109 12 120 + DF000000198.4 5654 0 5654 chr6 170805979 31429885 31435550 29 31505811 2
par=$1
chr=${16}
ref_start=${18}
ref_end=${19}
par_start=${21}
par_end=$((par_start+ref_end-ref_start))
haplotype=${22}
dfam=${12%%.*}
# look at the actual sequence in the participant to check for no calls
nocalls=$(./count_nocalls.sh $par $chr $par_start $par_end $haplotype)
echo No-call percentage $nocalls
# this test looks at a small region to ensure that the deletion is not due to the hard limit of 16 blat matches per strand
./blat -minIdentity=80 data/${par}/fasta_${par}_${chr}_${haplotype}.2bit:${chr}:${par_start}-${par_end} hervs/${dfam}.fa stillnotthere.psl
head -n 6 stillnotthere.psl
./twoBitToFa hg38/${chr}.2bit:${chr}:$((ref_start-2000))-$((ref_start)) leftflank.fa
./blat -minIdentity=80 data/${par}/fasta_${par}_${chr}_${haplotype}.2bit:${chr}:$((par_start-100000))-$((par_end+100000)) leftflank.fa leftflank.psl
head -n 6 leftflank.psl
./twoBitToFa hg38/${chr}.2bit:${chr}:$((ref_end))-$((ref_end+2000)) rightflank.fa
./blat -minIdentity=80 data/${par}/fasta_${par}_${chr}_${haplotype}.2bit:${chr}:$((par_start-100000))-$((par_end+100000)) rightflank.fa rightflank.psl
head -n 6 rightflank.psl 