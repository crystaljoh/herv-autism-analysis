# apply this script to the list of accession numbers in hervs_to_fetch_from_genbank e.g.
# cat hervs_to_fetch_from_genbank | xargs -n 1 ./fetch_herv.sh
# This typically procduces a fair bit of error output.
# It also sometimes fails to fetch the fasta, resulting in a 0 length output file.
# If this happens, checking the revision number at genbank and including that
# may fix the problem e.g. AF164611.1
esearch -db nuccore -query $1 | efetch -format fasta > $1.fa
