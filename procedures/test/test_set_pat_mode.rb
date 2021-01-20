#Test Script - Set PAT Mode
#Assumed Path: #C:\BCT\71sw0078_a_cosmos_click_edu\procedures\test\test_set_pat_mode.rb

load 'C:/BCT/71sw0078_a_cosmos_click_edu/procedures/lib/pl_cmd_tlm_apids.rb'
load 'C:/BCT/71sw0078_a_cosmos_click_edu/procedures/lib/click_cmd.rb'

#define data bytes
data = []
data[0] = PAT_MODE_STATIC_POINTING
packing = "C"

#SM Send via UUT PAYLOAD_WRITE
click_cmd(CMD_PL_SET_PAT_MODE, data, packing)