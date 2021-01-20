#Test Script - Request Payload File Downlink
#Assumed Path: #C:\BCT\71sw0078_a_cosmos_click_edu\procedures\test\test_request_file.rb

load 'C:/BCT/71sw0078_a_cosmos_click_edu/procedures/lib/pl_cmd_tlm_apids.rb'
load 'C:/BCT/71sw0078_a_cosmos_click_edu/procedures/lib/click_cmd.rb'

#define file path:
file_path = "/root/log/pat/tbd_image_name.png" #can get image name via list file command or via housekeeping tlm stream or PAT .txt telemetry file

#define data bytes
data = []
data[0] = file_path.length
data[1] = file_path 
packing = "C" + "a" + file_path.length.to_s

#SM Send via UUT PAYLOAD_WRITE
click_cmd(CMD_PL_REQUEST_FILE, data, packing)

#TODO: Get file telemetry...