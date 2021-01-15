#Test Script - Check if all chunks are received, and if so, assemble the chunks into a single file, delete staging dir
#Assumed Path: #C:\BCT\71sw0078_a_cosmos_click_edu\procedures\test_assemble_file.rb

load 'C:/BCT/71sw0078_a_cosmos_click_edu/procedures/lib/pl_cmd_tlm_apids.rb'
load 'C:/BCT/71sw0078_a_cosmos_click_edu/procedures/lib/click_cmd.rb'

#define data bytes
data = []
data[1] = 0x01
data[2] = 0x02
data[3] = 0x03
data[4] = 0x04
data[5] = 0x05
packing = "C*"

#SM Send via UUT PAYLOAD_WRITE
click_cmd(CMD_PL_ASSEMBLE_FILE, data, packing)

#TODO: Get echo telemetry...