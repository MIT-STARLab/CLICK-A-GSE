#Test Script - Check file hash against file
#Assumed Path: #C:\BCT\71sw0078_a_cosmos_click_edu\procedures\test_validate_file.rb

require 'FileUtils' # Pretty sure COSMOS already requires this, so this is might be unnecessary
require 'digest/md5'
load 'C:/BCT/71sw0078_a_cosmos_click_edu/procedures/lib/pl_cmd_tlm_apids.rb'
load 'C:/BCT/71sw0078_a_cosmos_click_edu/procedures/lib/click_cmd.rb'

file_name = '/root/bin/pat' #path or name?
md5 = Digest::MD5.file file_name #what's the packing type? uint8 or string...

#define data bytes
data = []
data[0] = md5
data[1] = file_name.length
data[2] = file_name 
packing = "C" + md5.length.to_s + "S>" + "a" + file_name.length.to_s

#SM Send via UUT PAYLOAD_WRITE
click_cmd(CMD_PL_VALIDATE_FILE, data, packing)

#TODO: Get telemetry...