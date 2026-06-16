mkdir -p hervs
cd all_hervs
cat hervs_to_fetch_from_genbank | xargs -n 1 ./fetch_herv.sh
cd ..