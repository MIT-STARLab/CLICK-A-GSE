#Test Script - Execute Payload File
#Assumed Path: #C:\BCT\71sw0078_a_cosmos_click_edu\procedures\test\test_execute_file.rb

load 'C:/BCT/71sw0078_a_cosmos_click_edu/procedures/lib/pl_cmd_tlm_apids.rb'
load 'C:/BCT/71sw0078_a_cosmos_click_edu/procedures/lib/click_cmd.rb'

#define file path:
file_path = "/root/bin/pat"

#define data bytes
data = []
data[0] = 0x00 #output script prints to file? Enable = 0xFF, Disable = 0x00
data[1] = 0 #file output number (if outputting script prints to file)
data[2] = file_path.length
data[3] = file_path 
packing = "C3" + "a" + file_path.length.to_s

#SM Send via UUT PAYLOAD_WRITE
click_cmd(CMD_PL_EXEC_FILE, data, packing) 

#TODO: Get file output telemetry...