# Setting up and running blat workflow in Workbench Jupyter app

The scripts here need to be run in a terminal window in a Jupyter app

# Initial setup

Fasta files are excluded from storage in git to avoid exfiltration of data. Short of defeating that behavior by editing the .gitignore file, we need to retrieve both the hg38 reference genome data and any HERV fasta files we wish to search for.

To retrieve the hg38 data execute the following in a terminal window when located in the blat directory

```
source ./all_chromosomes.sh
source ./get_ref.sh
```

Also retrieve some hervs from genbank. This will put the fasta files in the all_hervs subdirectory.
There will be some error messages printed, but some zero length files may result
```
cd all_hervs
cat hervs_to_fetch_from_genbank | xargs -n 1 ./fetch_herv.sh
cd ..
```

Pick some hervs to analyze and copy their fasta files from all_hervs to hervs directory e.g.
```
cp all_hervs/AF164610.fa hervs
```
Decide which chromosomes you wish to analyze. There are two scripts; for just chr21, chr22 and chrY execute
```
source ./short_chromosomes.sh
```
and for all chromosomes
```
source ./all_chromosomes.sh
```
In order to create participant assemblies from the CRAM files you need to set a variable
```
export generate_fasta=1
```
Then run the blat script on the reference genome like this
```
./participant.sh ref
```
This will generate a few error messages - I will tidy those up soon.
You only need to rerun this script when you change the set of chromosomes or hervs you are analyzing.

Then you can run the script for a particular participant, e.g. for 1234567
```
./participant.sh 1234567
```
This will create output files in the output subdirectory with names starting with 'results'.
Any that are non-empty will contain records for insertions or deletions.