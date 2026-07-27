# Setting up and running blat workflow in Workbench Jupyter app

The scripts here need to be run in a terminal window in a Jupyter app

# Initial setup


I have added all the herv fasta files from DFam to the github repository, so they are all avaliable in all_hervs directory.

Pick some hervs to analyze and copy their fasta files from all_hervs to hervs directory e.g.
```
cp all_hervs/DF000000174.fa hervs
```
Decide which chromosomes you wish to analyze. There are two scripts; for just chr21, chr22 and chrY execute
```
source ./short_chromosomes.sh
```
and for all chromosomes
```
source ./all_chromosomes.sh
```
To select a different set of chromosomes, set the environment variable chromosomes to the set e.g.
```
export chromosomes="chr1 chr2"
```
Each time you change either the set of hervs being searched for, or the set of chromosomes, you must perform the blat searches on the reference genome hg38 by executing
```
./participant.sh ref
```
You only need to rerun this script when you change the set of chromosomes or hervs you are analyzing.

Then you can run the script for a particular participant, e.g. for 1234567
```
./participant.sh 1234567
```
This does two things
- Retrieves the CRAM file for the participant (if necessary) and creates assemblies from it for the selected chromosomes. The fasta files of these assemblies are placed in the `data` subdirectory. These can also be used by RetroTector
- Runs blat searches for the hervs present in the `hervs` subdirectory and compares the results with those obtained from the reference

This will create output files in the results subdirectory named for the participant id e.g.
```
results/mismatches_1234567.txt
```
This has a pair of lines starting with "Match" for each match found between the reference and the participant. One showing the psl output for the reference and one for the participant. These are mostly for debugging to ensure that matches are being found! If there is a deletion, there will be a line starting "Deletion" with the psl output for the reference. If there is an insertion, there will be a line starting "Insertion" with the psl output for the participant.

Note that repeated runs just append to this file, so for a fresh run, delete this file first.
