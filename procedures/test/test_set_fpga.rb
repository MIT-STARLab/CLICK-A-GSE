#Test Script - Set FPGA memory map values 
#Assumed Path: #C:\BCT\71sw0078_a_cosmos_click_edu\procedures\test_set_fpga.rb

load 'C:/BCT/71sw0078_a_cosmos_click_edu/procedures/lib/pl_cmd_tlm_apids.rb'
load 'C:/BCT/71sw0078_a_cosmos_click_edu/procedures/lib/click_cmd.rb'

#define request number, start address, and data to write
request_number = 0
start_address = "0x0035"
write_data = "0x0085"

#define data bytes
data = []
data[0] = request_number
data[1] = start_address
data[2] = write_data.length
data[3] = write_data
packing = "CL>C" + "L>" + write_data.length.to_s

#SM Send via UUT PAYLOAD_WRITE
click_cmd(CMD_PL_SET_FPGA, data, packing)

#TODO: Get FGPA answer telemetry...