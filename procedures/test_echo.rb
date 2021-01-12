#Test Script - Echo
#Assumed Path: #C:\BCT\71sw0078_a_cosmos_click_edu\procedures\test_echo.rb

load 'click_cmd.rb'

#define CMD_ID
CMD_ID_PL_ECHO = 0x3D #cmd_ids defined here: https://docs.google.com/spreadsheets/d/1ITNdvtceonKRpWd4pGuhg9Do2ZygTLGonbsYKwVzycM/edit#gid=1522568728

#define data bytes
echo_data = [0x01,0x02,0x03,0x04,0x05]
echo_data_packed = echo_data.pack("C*")

#SM Send 
click_cmd(CMD_ID_PL_ECHO, echo_data_packed)