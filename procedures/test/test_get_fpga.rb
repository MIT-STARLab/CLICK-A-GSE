#Test Script - Get FPGA memory map values 
#Assumed Path: #C:\BCT\71sw0078_a_cosmos_click_edu\procedures\test_get_fpga.rb

load 'C:/BCT/71sw0078_a_cosmos_click_edu/procedures/lib/pl_cmd_tlm_apids.rb'
load 'C:/BCT/71sw0078_a_cosmos_click_edu/procedures/lib/click_cmd.rb'

#define request number, start address, and data to write
request_number = 0
start_address = "0x0035"
num_registers = 1

#define data bytes
data = []
data[0] = request_number
data[1] = start_address
data[2] = num_registers
packing = "CL>C"

#SM Send via UUT PAYLOAD_WRITE
click_cmd(CMD_PL_GET_FPGA, data, packing)

#TODO: Get FGPA answer telemetry...