mkdir -p hg38
cd hg38
for chr in $chromosomes; do
    wget https://hgdownload.soe.ucsc.edu/goldenPath/hg38/chromosomes/$chr.fa.gz
    gunzip $chr.fa.gz
    ../faToTwoBit $chr.fa $chr.2bit
    rm $chr.fa
done
gsutil cp gs://gcp-public-data--broad-references/hg38/v0/Homo_sapiens_assembly38.fasta .
gsutil cp gs://gcp-public-data--broad-references/hg38/v0/Homo_sapiens_assembly38.fasta.fai .
cd ..