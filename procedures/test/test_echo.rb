#Test Script - Echo
#Assumed Path: #C:\BCT\71sw0078_a_cosmos_click_edu\procedures\test_echo.rb

load 'C:/BCT/71sw0078_a_cosmos_click_edu/procedures/lib/pl_cmd_tlm_apids.rb'
load 'C:/BCT/71sw0078_a_cosmos_click_edu/procedures/lib/click_cmd.rb'

#echo data
echo_data = 'HelloWorld'
#define data bytes
data = []
data[0] = echo_data
packing = "a" + echo_data.length.to_s

#SM Send via UUT PAYLOAD_WRITE
click_cmd(CMD_PL_ECHO, data, packing)

#TODO: Get echo telemetry...