#Test Script - List Payload Files in a Given Directory
#Assumed Path: #C:\BCT\71sw0078_a_cosmos_click_edu\procedures\test_list_file.rb

load 'C:/BCT/71sw0078_a_cosmos_click_edu/procedures/lib/pl_cmd_tlm_apids.rb'
load 'C:/BCT/71sw0078_a_cosmos_click_edu/procedures/lib/click_cmd.rb'

#define directory path:
directory_path = "/root/bin"

#define data bytes
data = []
data[0] = directory_path.length
data[1] = directory_path 
packing = "C" + "a" + directory_path.length.to_s

#SM Send via UUT PAYLOAD_WRITE
click_cmd(CMD_PL_LIST_FILE, data, packing)

#TODO: Get file list telemetry...