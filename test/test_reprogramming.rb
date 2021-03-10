# Reprogramming macro and golden image must be present on bus
# See ../macros/load_reprogramming.rb
macro_id = 65
trn_id = 1
img_path = "/mnt/sd/general/testzeros"

# Run reprogramming init macro
cmd("UUT MACRO_EXECUTE with MACRO_ID #{macro_id}")

# Wait for init to finish
wait(30)

# Start golden image transmission
cmd("UUT PYLD_CFDP_DL_FILE with PKT_LEN 62, CCSDS_AP_ID 496, TRN_ID #{trn_id}, SRC_PATH #{img_path}")
