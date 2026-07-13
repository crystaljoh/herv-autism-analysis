# field in PSL format
#  1 matches - Number of matching bases that aren't repeats.
#  2 misMatches - Number of bases that don't match.
#  3 repMatches - Number of matching bases that are part of repeats.
#  4 nCount - Number of 'N' bases.
#  5 qNumInsert - Number of inserts in query.
#  6 qBaseInsert - Number of bases inserted into query.
#  7 tNumInsert - Number of inserts in target.
#  8 tBaseInsert - Number of bases inserted into target.
#  9 strand - defined as + (forward) or - (reverse) for query strand.
# 10 qName - Query sequence name.
# 11 qSize - Query sequence size.
# 12 qStart - Alignment start position in query.
# 13 qEnd - Alignment end position in query.
# 14 tName - Target sequence name.
# 15 tSize - Target sequence size.
# 16 tStart - Alignment start position in target.
# 17 tEnd - Alignment end position in target.
# 18 blockCount - Number of blocks in the alignment.
# 19 blockSizes - Comma-separated list of sizes of each block.
# 20 qStarts - Comma-separated list of start position of each block in query.
# 21 tStarts - Comma-separated list of start position of each block in target.

function abs(a)
{
    if (a < 0)
	return -a
    else
	return a
}
{
    if (FILENAME == ARGV[1]) {
    	# first file is the reference
    	for (i = 1; i <= 18; i++) {
    	    ref[FNR,i] = $i
    	}
    	ref_size = FNR
    	ref_matched[FNR] = 0
    	ref_line[FNR] = $0
    }
    else {
    	if ((($1 / $11) > threshold) && (($17 - $16) < (2 * $11))) {
        	matched = 0
            # ref match has to be substantial as well
        	for (i = 1; i <= ref_size; i++) {
        	    if ((ref_matched[i] == 0) && (abs(ref[i,16] - $16) < slack) && ((ref[i,1] / ref[i,11]) > (threshold / 2))) {
            		matched = 1
        	        ref_matched[i] = 1
            		break
        	    }
        	}
            if (matched == 0) {
        	    printf "%s%s", "Insertion", OFS
                for(j=1; j<=18; j++) printf "%s%s", $j, (j==18 ? ORS : OFS)
            }
            else {
                printf "%s%s", "Match    ", OFS
                for(j=1; j<=18; j++) printf "%s%s", $j, (j==18 ? ORS : OFS)
    	        printf "%s%s", "and      ", OFS
                for(j=1; j<=18; j++) printf "%s%s", ref[i,j], (j==18 ? ORS : OFS)
            }
        }
    }
}
END {
    for (i = 1; i <= ref_size; i++) {
    	if ((ref_matched[i] == 0) && ((ref[i,1] / ref[i,11]) > threshold) && ((ref[i,17] - ref[i,16]) < (2 * ref[i,11]))) {
    	    printf "%s%s", "Deletion ", OFS
            for(j=1; j<=18; j++) printf "%s%s", ref[i,j], (j==18 ? ORS : OFS)
        }
    }
}
