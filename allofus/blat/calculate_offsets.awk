BEGIN {
    deletion = "deletion"
    insertion = "insertion"
    alignment = "alignment"
    state = "begin"
    reference_position = 0
    participant_position = 0
}
{
    if (NR == 1) {
        # print the firt header line, do not process
        print $0
        next
    }
    if (substr($0, 1, 1) == ">") {
        # skip any internal header lines
        next
    }
    for (i = 1; i <= length; i++) {
        base = substr($0, i, 1)
        if (base == "*") {
            # deletion
            next_state = deletion
            reference_position++
        } else if (base == "_") {
            # insertion
            i++
            printf "%s", substr($0, i, 1)
            participant_position++
            next_state = insertion
        }
        else {
            # alignment
            printf "%s", base
            next_state = alignment
            reference_position++
            participant_position++
        }
        if (state != next_state)  {
            print participant_position, reference_position, state, "->", next_state > offsets_file 
            state = next_state
        }
    }
    printf "%s", ORS
}
END {
    print participant_position, reference_position, state, "end" > offsets_file 
}
