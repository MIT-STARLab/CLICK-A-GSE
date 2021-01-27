#Test Script - Check if all chunks are received, and if so, assemble the chunks into a single file, delete staging dir
#Assumed Path: #C:\BCT\71sw0078_a_cosmos_click_edu\procedures\test\test_assemble_file.rb

load 'C:/BCT/71sw0078_a_cosmos_click_edu/procedures/lib/pl_cmd_tlm_apids.rb'
load 'C:/BCT/71sw0078_a_cosmos_click_edu/procedures/lib/click_cmd.rb'

transfer_id = 1 #TBR
file_name = "/bin/pat" #TBR (should it just be the file name or the whole path?)

#define data bytes
data = []
data[0] = transfer_id
data[1] = file_name.length
data[2] = file_name 
packing = "S>2" + "a" + file_name.length.to_s

#SM Send via UUT PAYLOAD_WRITE
click_cmd(CMD_PL_ASSEMBLE_FILE, data, packing)

#TODO: Get telemetry...