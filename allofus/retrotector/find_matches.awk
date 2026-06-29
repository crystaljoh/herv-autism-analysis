function abs(a)
{
    if (a < 0)
	return -a
    else
	return a
}
BEGIN {
  print "Finding inserted and deleted HERVS..."
  ref_size = 0
}
{
    if ($3 == "Env") {
    if (FILENAME == ARGV[1]) {
	# first file is the reference
    ref_size = ref_size + 1
	for (i = 1; i <= 6; i++) {
	    ref[ref_size,i] = $i
	}
	ref_matched[ref_size] = 0
	ref_line[ref_size] = $0
    }
    else {
	matched = 0
	for (i = 1; i <= ref_size; i++) {
	    if ((ref_matched[i] == 0) && (abs(ref[i, 1] - $1) < slack)) {
		matched = 1
	    ref_matched[i] = 1
        print "Match", ref_line[i]
		break
	    }
	}
	if (matched == 0)
	    print "Insertion", $0
    }
}
}
END {
    print "Number of env in reference:", ref_size
    for (i = 1; i <= ref_size; i++) {
	if (ref_matched[i] == 0)
	    print "Deletion", ref_line[i]
    }
}
