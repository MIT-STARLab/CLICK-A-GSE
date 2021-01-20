#Test Script - Delete file
#Assumed Path: #C:\BCT\71sw0078_a_cosmos_click_edu\procedures\test\test_delete_file.rb

load 'C:/BCT/71sw0078_a_cosmos_click_edu/procedures/lib/pl_cmd_tlm_apids.rb'
load 'C:/BCT/71sw0078_a_cosmos_click_edu/procedures/lib/click_cmd.rb'

recursive = 0x00 #NO, 0xFF = YES
file_name = "/bin/pat" #TBR path or name?

#define data bytes
data = []
data[0] = recursive
data[1] = file_name.length
data[2] = file_name 
packing = "CS>" + "a" + file_name.length.to_s

#SM Send via UUT PAYLOAD_WRITE
click_cmd(CMD_PL_DEL_FILE, data, packing)

#TODO: Get telemetry...