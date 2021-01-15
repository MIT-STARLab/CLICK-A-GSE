#Test Script - Take pictures of cal laser spot at 4 different FSM settings.
#Assumed Path: #C:\BCT\71sw0078_a_cosmos_click_edu\procedures\test_fsm.rb

load 'C:/BCT/71sw0078_a_cosmos_click_edu/procedures/lib/pl_cmd_tlm_apids.rb'
load 'C:/BCT/71sw0078_a_cosmos_click_edu/procedures/lib/click_cmd.rb'

#set desired exposure time (us) (between 10 and 10000000)
exp_us = 1000

#define data bytes
data = []
data[0] = exp_us
packing = "L>"

#SM Send via UUT Payload Write
click_cmd(CMD_PL_FSM_TEST, data, packing)

#TODO: Get image telemetry...