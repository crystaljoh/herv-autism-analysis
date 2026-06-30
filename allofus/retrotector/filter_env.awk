function abs(a)
{
    if (a < 0)
	return -a
    else
	return a
}
BEGIN {
    put_size = 0
    last_start = 0
    max_herv_size = 8000
    gene_name[1] = "Gag"
    gene_name[2] = "Pol"
    gene_name[3] = "Pro"
}
{
    # crude duplicate detection
    if ($1 != last_start) {
        last_start = $1
        put_size = put_size + 1
        for (i = 1; i <= 6; i++) {
        	put[put_size,i] = $i
        }
        put_line[put_size] = $0
    }
}
END {
    for (i = 1; i <= put_size; i++) {
        if (put[i,3] == "Env") {
            # print "Trying", put_line[i]
            for (j = 1; j <= 3; j++) {
                found_gene[j] = 0
            }
            # OK, this is O(N*N) but N is relatively small
            for (k = 1; k <= put_size; k++) {
                if (abs(put[i, 1] - put[k, 1]) < max_herv_size) {
                    for (j = 1; j <= 3; j++) {
                        if (gene_name[j] == put[k, 3]) {
                            # print "Found matching", put_line[k]
                            found_gene[j] = k
                        }
                    }
                }
            }
            found_all_genes = 1
            for (j = 1; j <= 3; j++) {
                if (found_gene[j] == 0) {
                    found_all_genes = 0;
                }
            }
            if (found_all_genes == 1) {
                print put_line[i]
                # for (j = 1; j <= 3; j++) {
                #    print put_line[found_gene[j]]
                # }
            }
        }
    }
}
