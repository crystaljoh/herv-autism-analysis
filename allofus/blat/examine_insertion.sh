# commands to examine an apparent insertion
# example line to pass to this script (x are don't care)
# the line is exactly as found for a insertion in one of the mismatches_only files, with the participant_id added at the front
# participant_id x x x x x x x x x x x DFAM_accession_number x x x chromosome x par_start par_end x ref_start haplotype
# 1023419 Insertion 6865 323 0 39 4 309 5 15 - DF000000188.5 7536 0 7536 chr1 249292396 73299073 73306315 9 73130271 1
par=$1
chr=${16}
par_start=${18}
par_end=${19}
ref_start=${21}
ref_end=$((ref_start+par_end-par_start))
haplotype=${22}
dfam=${12%%.*}
# look at the actual sequence in the ref to check for no calls
nocalls=$(./count_nocalls.sh $par $chr $ref_start $ref_end $haplotype)
echo No-call percentage $nocalls
# this test looks at a small region to ensure that the insertion is not due to the hard limit of 16 blat matches per strand
# a strong match would suggest that it is in fact present in the reference
./blat -minIdentity=80 data/${par}/fasta_${par}_${chr}_${haplotype}.2bit:${chr}:${ref_start}-${ref_end} hervs/${dfam}.fa stillnotthere.psl
head -n 6 stillnotthere.psl
./twoBitToFa hg38/${chr}.2bit:${chr}:$((ref_start-2000))-$((ref_start)) leftflank.fa
./blat -minIdentity=80 data/${par}/fasta_${par}_${chr}_${haplotype}.2bit:${chr}:$((par_start-100000))-$((par_end+100000)) leftflank.fa leftflank.psl
head -n 6 leftflank.psl
./twoBitToFa hg38/${chr}.2bit:${chr}:$((ref_start))-$((ref_start+2000)) rightflank.fa
./blat -minIdentity=80 data/${par}/fasta_${par}_${chr}_${haplotype}.2bit:${chr}:$((par_start-100000))-$((par_end+100000)) rightflank.fa rightflank.psl
head -n 6 rightflank.psl 