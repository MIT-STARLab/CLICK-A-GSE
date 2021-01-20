#Test Script - Execute Payload Self Test
#Assumed Path: #C:\BCT\71sw0078_a_cosmos_click_edu\procedures\test\test_self_test.rb

load 'C:/BCT/71sw0078_a_cosmos_click_edu/procedures/lib/pl_cmd_tlm_apids.rb'
load 'C:/BCT/71sw0078_a_cosmos_click_edu/procedures/lib/click_cmd.rb'

#define data bytes
data = []
data[0] = TEST_PAT_HW
packing = "C"

#SM Send via UUT PAYLOAD_WRITE
click_cmd(CMD_PL_SELF_TEST, data, packing)