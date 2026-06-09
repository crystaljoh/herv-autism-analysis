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
	for (i = 1; i <= 17; i++) {
	    ref[FNR,i] = $i
	}
	ref_size = FNR
	ref_matched[FNR] = 0
	ref_line[FNR] = $0
    }
    else {
	matched = 0
	for (i = 1; i <= ref_size; i++) {
	    if ((ref_matched[i] == 0) && (abs(ref[i,16] - $16) < slack)) {
		matched = 1
	        ref_matched[i] = 1
		break
	    }
	}
	if ((matched == 0) && (($1 / $11) > threshold) && (($17 - $16) < (2 * $11)))
	    print "Insertion", $0
    }
}
END {
    for (i = 1; i <= ref_size; i++) {
	if ((ref_matched[i] == 0) && ((ref[i,1] / ref[i,11]) > threshold) && ((ref[i,17] - ref[i,16]) < (2 * ref[i,11])))
	    print "Deletion", ref_line[i]
    }
}
