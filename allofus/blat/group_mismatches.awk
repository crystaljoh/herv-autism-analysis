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
        insertions_by_herv[$12]++
    }
    if (prev[2] == "Deletion") {
        deletions++
        deletions_by_herv[$12]++
    }
}
    
BEGIN {
    count = 0
    insertions = 0
    deletions = 0
    num_participants = 0
}
{
    if (!($1 in participant_indices)) {
        num_participants++
        participant_indices[$1] = num_participants
    }
    participant_index = participant_indices[$1]
    if ($2 == "Insertion") {
        insertions_by_participant[$1]++
    }
    if (prev[2] == "Deletion") {
        deletions_by_participant[$1]++
    }
    if ($2 != prev[2] || $13 != prev[13] || $17 != prev[17] || ($2 == "Deletion" && abs($19 - prev[19]) > 10000) || ($2 == "Insertion" && abs($22 - prev[22]) > 10000)) {
        process_end()
    }
    count = count + 1
    if (count == 1) {
        for (i=2; i<=NF; i++) {
            printf "%s%s", $i, OFS
        }
        printf "%s", ORS
        printf "%s%s", "Participant_indices:", OFS
    }
    printf "%s%s", participant_index, OFS
    for (i=1; i<= NF; i++) {
        prev[i] = $i
    }
}
END {
    process_end()
    print "Distinct Insertions: ", insertions, "Distinct Deletions: ", deletions
    PROCINFO["sorted_in"] = "@val_num_desc"
    for (herv in insertions_by_herv) {
        print "Insertions", herv, insertions_by_herv[herv]
    }
    for (herv in deletions_by_herv) {
        print "Deletions", herv, deletions_by_herv[herv]
    }
    for (participant in deletions_by_participant) {
        print "Participant index", participant_indices[participant], "Insertions:", insertions_by_participant[participant], "Deletions:", deletions_by_participant[participant]
    }
    for (participant in participant_indices) {
        print "Participant index", participant_indices[participant], "participant", participant
    }
}