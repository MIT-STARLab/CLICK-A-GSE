#Test Script - Echo
#Assumed Path: #C:\BCT\71sw0078_a_cosmos_click_edu\procedures\test_echo.rb

load 'pl_cmd_tlm_apids.rb'
load 'click_cmd.rb'

#define data bytes
data = [0x01,0x02,0x03,0x04,0x05]
packing = "C*"

#SM Send via UUT PAYLOAD_WRITE
click_cmd(CMD_PL_ECHO, data, packing)

#TODO: Get echo telemetry...