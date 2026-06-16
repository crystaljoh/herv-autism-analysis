mkdir -p hg38
cd hg38
for chr in $chromosomes; do
    if [ ! -f $chr.2bit ]
    then
        wget https://hgdownload.soe.ucsc.edu/goldenPath/hg38/chromosomes/$chr.fa.gz
        gunzip $chr.fa.gz
        ../faToTwoBit $chr.fa $chr.2bit
        # do not remove the fasta file because we might use it for RetroTector
        # rm $chr.fa
    fi
done
if [ ! -f Homo_sapiens_assembly38.fasta ] 
then 
    gsutil cp gs://gcp-public-data--broad-references/hg38/v0/Homo_sapiens_assembly38.fasta .
    gsutil cp gs://gcp-public-data--broad-references/hg38/v0/Homo_sapiens_assembly38.fasta.fai .
fi
cd ..