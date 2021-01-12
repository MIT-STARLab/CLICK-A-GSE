#Test Script - Set PAT Mode
#Assumed Path: #C:\BCT\71sw0078_a_cosmos_click_edu\procedures\test_set_pat_mode.rb

load 'pl_cmd_tlm_apids.rb'
load 'click_cmd.rb'

#define mode ids
PAT_MODE_OPEN_LOOP = 1
PAT_MODE_STATIC_POINTING = 2
PAT_MODE_BUS_FEEDBACK = 3

#define data bytes
data = []
data[0] = PAT_MODE_STATIC_POINTING
packing = "C"

#SM Send via UUT PAYLOAD_WRITE
click_cmd(CMD_PL_SET_PAT_MODE, data, packing)