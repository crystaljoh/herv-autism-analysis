function abs(a)
{
    if (a < 0)
	return -a
    else
	return a
}
function process_end()
{
    if (count > 0) {
        print "Count:", count
    }
    count = 0
    printf "%s", ORS
    if (prev[2] == "Insertion") {
        insertions++
    }
    if (prev[2] == "Deletion") {
        deletions++
    }
}
    
BEGIN {
    count = 0
    insertions = 0
    deletions = 0
}
{
    if ($2 != prev[2] || $13 != prev[13] || $17 != prev[17] || ($2 == "Deletion" && abs($19 - prev[19]) > 10000) || ($2 == "Insertion" && abs($22 - prev[22]) > 10000)) {
        process_end()
    }
    count = count + 1
    print $0
    for (i=1; i<= NF; i++) {
        prev[i] = $i
    }
}
END {
    process_end()
    print "Insertions: ", insertions, "Deletions: ", deletions
}