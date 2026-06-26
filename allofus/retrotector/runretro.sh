# execute in herv-autism-analysis/allofus/retrotector/RetroTector-main/ReTe1.0.1
# ../../runretro.sh <participant_id> <chromosome> <haplotype>
# before running this you must have run the blat participant script for the participant and chromosome used
# in order to create the fasta file for the participant chromosome
participant_id=$1
chromosome=$2
haplotype=$3
rm -rf Workplace_${participant_id}_${chromosome}_${haplotype}
mkdir -p Workplace_${participant_id}_${chromosome}_${haplotype}/NewDNA
if [ $participant_id = "ref" ]
then
    haplotype=0
    cp ../../../blat/hg38/${chromosome}.fa Workplace_${participant_id}_${chromosome}_${haplotype}/NewDNA
else
    cp ../../../blat/data/fasta_${participant_id}_${chromosome}_${haplotype}.fa Workplace_${participant_id}_${chromosome}_${haplotype}/NewDNA
fi
java -Xmx768m -classpath RetroTectorEngine.jar:. retrotector/RetroTectorEngine D:$(pwd)/Workplace_${participant_id}_${chromosome}_${haplotype} SweepDNA quit
java -Xmx768m -classpath RetroTectorEngine.jar:. retrotector/RetroTectorEngine D:$(pwd)/Workplace_${participant_id}_${chromosome}_${haplotype} SweepScripts quit
