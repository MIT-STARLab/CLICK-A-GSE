#Test Script - Configure Optical Downlink
#Assumed Path: #C:\BCT\71sw0078_a_cosmos_click_edu\procedures\test_dwnlink_mode.rb

load 'click_cmd.rb'

#define CMD_ID
CMD_ID_PL_CONFIG_OPTICAL_DOWNLINK = 0xE0 #cmd_ids defined here: https://docs.google.com/spreadsheets/d/1ITNdvtceonKRpWd4pGuhg9Do2ZygTLGonbsYKwVzycM/edit#gid=1522568728

#DC Send (i.e. send CMD_ID only with empty data field)
click_cmd(CMD_ID_PL_CONFIG_OPTICAL_DOWNLINK, [])