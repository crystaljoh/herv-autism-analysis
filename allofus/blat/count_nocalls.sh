par=$1
chr=$2
start=$3
end=$4
haplotype=$5
filenam=$(mktemp)
./twoBitToFa data/${par}/fasta_${par}_${chr}_${haplotype}.2bit:${chr}:${start}-${end} ${filenam}
nocalls=$(tr -cd 'N' < $filenam | wc -m)
rm ${filenam}
echo $((nocalls*100/(end-start)))
