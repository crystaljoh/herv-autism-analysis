# commands to examine an apparent deletion
# example line to pass to this script (x are don't care)
# participant_id x x x x x x x x x x x DFAM_accession_number x x x chromosome x ref_start ref_end x par_start haplotype
# 1023419 Deletion 5032 233 0 8 23 246 20 383 - LTR2B-int DF003576587.2 5520 0 5519 chr1 248956422 1412721 1418377  32 1423212 2
par=$1
chr=${17}
ref_start=${19}
ref_end=${20}
par_start=${22}
par_end=$((par_start+ref_end-ref_start))
haplotype=${23}
dfam=${13%%.*}
# look at the actual sequence in the participant to check for no calls
./twoBitToFa data/${par}/fasta_${par}_${chr}_${haplotype}.2bit:${chr}:${par_start}-${par_end} herv.fa
nocalls=$(tr -cd 'N' < herv.fa | wc -m)
echo Number of no-calls $nocalls, or $((nocalls*100/(par_end-par_start)))\%
# this test looks at a small region to ensure that the deletion is not due to the hard limit of 16 blat matches per strand
./blat -minIdentity=80 data/${par}/fasta_${par}_${chr}_${haplotype}.2bit:${chr}:${par_start}-${par_end} hervs/${dfam}.fa stillnotthere.psl
head -n 6 stillnotthere.psl
./twoBitToFa hg38/${chr}.2bit:${chr}:$((ref_start-2000))-$((ref_start)) leftflank.fa
./blat -minIdentity=80 data/${par}/fasta_${par}_${chr}_${haplotype}.2bit:${chr}:$((par_start-100000))-$((par_end+100000)) leftflank.fa leftflank.psl
head -n 6 leftflank.psl
./twoBitToFa hg38/${chr}.2bit:${chr}:$((ref_end))-$((ref_end+2000)) rightflank.fa
./blat -minIdentity=80 data/${par}/fasta_${par}_${chr}_${haplotype}.2bit:${chr}:$((par_start-100000))-$((par_end+100000)) rightflank.fa rightflank.psl
head -n 6 rightflank.psl