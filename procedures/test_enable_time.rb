#Test Script - Payload Enable Updating System Time from Time-At-Tone Packets
#Assumed Path: #C:\BCT\71sw0078_a_cosmos_click_edu\procedures\test_enable_time.rb

load 'pl_cmd_tlm_apids.rb'
load 'click_cmd.rb'

#DC Send via UUT Payload Write (i.e. send CMD_ID only with empty data field)
click_cmd(CMD_PL_ENABLE_TIME)