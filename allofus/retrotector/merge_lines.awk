{
if (NR%4==1) {
    filenam = $1
}
if (NR%4==2) {
    start_position = substr($5, 1, length($5)-1)
    end_position = $8
}
if (NR%4==3) {
    genus = $3
}
if (NR%4==0) {
    gene = $3
    print "Start ", start_position, "End ", end_position, "Genus ", genus, "Gene ", gene, "Filename ", filenam
}
}