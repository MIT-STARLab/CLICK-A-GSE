#Test Script - Configure Debug Mode
#Assumed Path: #C:\BCT\71sw0078_a_cosmos_click_edu\procedures\test_debug_mode.rb

load 'click_cmd.rb'

#define CMD_ID
CMD_ID_PL_CONFIG_DEBUG = 0xD0 #cmd_ids defined here: https://docs.google.com/spreadsheets/d/1ITNdvtceonKRpWd4pGuhg9Do2ZygTLGonbsYKwVzycM/edit#gid=1522568728

#DC Send via UUT PAYLOAD_WRITE (i.e. send CMD_ID only with empty data field)
click_cmd(CMD_ID_PL_CONFIG_DEBUG, [].pack("C*"))