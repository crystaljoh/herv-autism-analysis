BEGIN {
    in_deletion = 1
    in_insertion = 1
    reference_position = 1
    participant_position = 1
}
{
    if (NR == 1) {
        print $0
        next
    }
    for (i = 1; i <= length; i++) {
        base = substr($0, i, 1)
        if (base == "*") {
            # deletion
            in_deletion = 1
            reference_position++
        } else if (base == "_") {
            # insertion
            i++
            printf "%s", substr($0, i, 1)
            participant_position++
            in_insertion = 1
        }
        else {
            # alignment
            printf "%s", base
            if ((in_deletion == 1) || (in_insertion == 1))  {
                in_deletion = 0
                in_insertion = 0
                print participant_position, reference_position > offsets_file 
            }
            reference_position++
            participant_position++
        }
    }
    printf "%s", ORS
}
