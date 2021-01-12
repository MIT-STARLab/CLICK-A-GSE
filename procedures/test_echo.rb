#Test Script - Echo
#Assumed Path: #C:\BCT\71sw0078_a_cosmos_click_edu\procedures\test_echo.rb

load 'pl_cmd_tlm_apids.rb'
load 'click_cmd.rb'

#define data bytes
echo_data = [0x01,0x02,0x03,0x04,0x05]
echo_data_packed = echo_data.pack("C*")

#SM Send via UUT PAYLOAD_WRITE
click_cmd(CMD_PL_ECHO, echo_data_packed)