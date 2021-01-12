#Test Script - Execute Payload File
#Assumed Path: #C:\BCT\71sw0078_a_cosmos_click_edu\procedures\test_execute_file.rb

load 'pl_cmd_tlm_apids.rb'
load 'click_cmd.rb'

#define file path:
file_path = "/root/bin/pat"

#define data bytes
execute_file_data[0] = 0 #output script prints to file? [boolean]
execute_file_data[1] = 0 #file output number (if outputting script prints to file)
execute_file_data[2] = file_path.length
execute_file_data[3] = file_path 
packing_execute_file_data = "C3" + "a" + file_path.length.to_s
execute_file_data_packed = execute_file_data.pack(packing_execute_file_data)

#SM Send via UUT PAYLOAD_WRITE
click_cmd(CMD_PL_EXEC_FILE, execute_file_data_packed)