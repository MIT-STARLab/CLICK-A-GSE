#Test Script - Trigger PAT Capture of a Single Image
#Assumed Path: #C:\BCT\71sw0078_a_cosmos_click_edu\procedures\test_single_capture.rb

load 'pl_cmd_tlm_apids.rb'
load 'click_cmd.rb'

#set desired exposure time (us) (between 10 and 10000000)
exp_us = 1000

#define data bytes
data[0] = exp_us
packing = "L>"

#SM Send via UUT Payload Write
click_cmd(CMD_PL_SINGLE_CAPTURE, data, packing)

#TODO: Get image telemetry