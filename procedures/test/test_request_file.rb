#Test Script - Request Payload File Downlink
#Assumed Path: #C:\BCT\71sw0078_a_cosmos_click_edu\procedures\test\test_request_file.rb

load 'C:/BCT/71sw0078_a_cosmos_click_edu/procedures/lib/click_cmd_tlm.rb'

#define file path:
file_path = "/root/log/pat/tbd_image_name.png" #can get image name via list file command or via housekeeping tlm stream or PAT .txt telemetry file

#define data bytes
data = []
data[0] = file_path.length
data[1] = file_path 
packing = "C" + "a" + file_path.length.to_s

#SM Send via UUT PAYLOAD_WRITE
click_cmd(CMD_PL_REQUEST_FILE, data, packing)

#TODO: Get file telemetry...

### Re-assemble file...
# # Cosmos directory on the ground station computer
# cosmos_dir = "C:/BCT/71sw0078_a_cosmos_click_edu"
        
# # input the filename you want to chunk together: 
# filename = "test_file_uplink.txt"
# reconstructed_filename = "#{cosmos_dir}/outputs/data/uplink/reconstructed_"+filename
# puts reconstructed_filename

# # input the chunk names according to naming convention from downlink: 
# chunk_name = "45" #filename.split(".")[0]
# puts chunk_name
       
# ## retrieve how many chunks we have in chunks folder to put back together
# filelist =  Dir["#{cosmos_dir}/outputs/data/uplink/#{chunk_name}/*.chk"]
# num_chunks = filelist.length
# puts "file list #{filelist}"
# puts "num chunks #{num_chunks}"

# ## put file back together based on chunks in chunks folder: 
# i=0
# File.open(reconstructed_filename, 'wb') {|f| 
#   while i<num_chunks do
#   chunk_filename = "#{cosmos_dir}/outputs/data/uplink/#{chunk_name}/" + chunk_name + "_" + i.to_s + ".chk"
#   file = File.open("#{chunk_filename}", "rb")
#   chunk_contents = file.read.bytes
#   #print file_contents
#   chunk_length = chunk_contents.length
#   print("chunk contents length: #{chunk_length}\n")
#   f.write(chunk_contents.pack('C*'))
#   i+=1
#   end 
# }