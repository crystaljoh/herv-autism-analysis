# execute in herv-autism-analysis/allofus/retrotector/RetroTector-main/ReTe1.0.1
# ../../runretro.sh <participant_id> <chromosome> <haplotype>
participant_id=$1
chromosome=$2
haplotype=$3
rm -rf Workplace_${participant_id}_${chromosome}_${haplotype}
mkdir -p Workplace_${participant_id}_${chromosome}_${haplotype}/NewDNA
cp ../../../blat/data/fasta_${participant_id}_${chromosome}_${haplotype}.fa Workplace_${participant_id}_${chromosome}_${haplotype}/NewDNA
java -Xmx768m -classpath RetroTectorEngine.jar:. retrotector/RetroTectorEngine D:$(pwd)/Workplace_${participant_id}_${chromosome}_${haplotype} SweepDNA quit
java -Xmx768m -classpath RetroTectorEngine.jar:. retrotector/RetroTectorEngine D:$(pwd)/Workplace_${participant_id}_${chromosome}_${haplotype} SweepScripts quit
