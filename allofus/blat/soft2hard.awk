# Converts a SAM file with soft clipping to hard clipping
# by adjusting the CIGAR and truncating the SEQ
{
    if (substr($0, 1, 1) == "@") {
        print $0
        next
    }
    cigar = $6
    seq = $10
    softclipstartlen = 0
    softclipendlen = 0
    match(cigar, /^[0-9]+S/)
    if (RSTART != 0) {
        softclipstartlen = substr(cigar, 1, RLENGTH -1) + 0 # to convert to int
        seq = substr(seq, softclipstartlen + 1)
    }
    match(cigar, /[0-9]+S$/)
    if (RSTART != 0) {
        softclipendlen = substr(cigar, RSTART, RLENGTH-1) + 0
        seq = substr(seq, 1, length(seq) - softclipendlen)
    }
    gsub(/S/, "H", cigar)
    for(j=1; j<=5; j++) printf "%s%s", $j, OFS
    printf "%s%s", cigar, OFS
    for(j=7; j<=9; j++) printf "%s%s", $j, OFS
    printf "%s%s", seq, OFS
    for(j=11; j<=NF; j++) printf "%s%s", $j, OFS
    printf "%s", ORS
}



        
    
    