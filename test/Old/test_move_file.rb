#Test Script - Move/rename file
#Assumed Path: #C:\BCT\71sw0078_a_cosmos_click_edu\procedures\test\test_move_file.rb

load 'C:/BCT/71sw0078_a_cosmos_click_edu/procedures/lib/pl_cmd_tlm_apids.rb'
load 'C:/BCT/71sw0078_a_cosmos_click_edu/procedures/lib/click_cmd.rb'

source_file_name = '/root/bin/pat'
destination_file_name = '/root/pat'

#define data bytes
data = []
data[0] = source_file_path.length
data[1] = destination_file_path.length
data[2] = source_file_path 
data[3] = destination_file_path
packing = "S>2" + "a" + source_file_path.length.to_s + "a" + destination_file_path.length.to_s

#SM Send via UUT PAYLOAD_WRITE
click_cmd(CMD_PL_MOVE_FILE, data, packing)

#TODO: Get telemetry...