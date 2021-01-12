#Test Script - Configure Debug Mode
#Assumed Path: #C:\BCT\71sw0078_a_cosmos_click_edu\procedures\test_debug_mode.rb

load 'pl_cmd_tlm_apids.rb'
load 'click_cmd.rb'

#define (empty) data bytes
empty_data_packed = [].pack("C*")

#DC Send via UUT Payload Write (i.e. send CMD_ID only with empty data field)
click_cmd(CMD_PL_DEBUG_MODE, empty_data_packed)