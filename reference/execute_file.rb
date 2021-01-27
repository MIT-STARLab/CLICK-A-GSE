pathname = "/root/bin/pat"
pathname_len = length(pathname)
out_to_file = 0 # = no
outnum = 0 
cmd("UUT PL_EXEC_FILE with OUTPUT_TO_FILE #{out_to_file}, OUTNUM #{outnum}, PATHNAME_LEN #{pathname_len}, PATHNAME #{pathname}")