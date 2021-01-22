#Test Script - Uplink File to Payload 
#Note: this, like scp in Linux, will overwrite a pre-existing file with the same path on the payload
#Assumed Path: #C:\BCT\71sw0078_a_cosmos_click_edu\procedures\test\test_upload_file.rb

# 1. upload file chunks to staging (receive_file_chunk)
# 2. assemble file chunks (assemble_file) -> returns telemetry packet with status/errors/missing packet ids (staging directory isn't automatically deleted)
# 3. validate file with hash of file (validate file) -> returns error if it doesn't work
# 4. move file
# 5. delete
# (Hannah is working on automated version of this for file upload)

# *File request sends the file chunks down for the requested file

# Specify what packages the script needs
require 'FileUtils' # Pretty sure COSMOS already requires this, so this is might be unnecessary
require 'digest/md5'
load 'C:/BCT/71sw0078_a_cosmos_click_edu/procedures/lib/pl_cmd_tlm_apids.rb'
load 'C:/BCT/71sw0078_a_cosmos_click_edu/procedures/lib/click_cmd.rb'

def send_file_chunk(transfer_id, chunk_sequence_number, number_of_chunks_total, chunk_data_length, chunk_data)
    #define data bytes
    data = []
    data[0] = transfer_id
    data[1] = chunk_sequence_number
    data[2] = number_of_chunks_total 
    data[3] = chunk_data_length
    data[4] = chunk_data
    packing = "S>4" + "C" + chunk_data_length.to_s 

    #SM Send via UUT PAYLOAD_WRITE
    click_cmd(CMD_PL_UPLOAD_FILE, data, packing)
end

def assemble_file(transfer_id, file_path)
    #define data bytes
    data = []
    data[0] = transfer_id
    data[1] = file_path.length
    data[2] = file_path 
    packing = "S>2" + "a" + file_path.length.to_s

    #SM Send via UUT PAYLOAD_WRITE
    click_cmd(CMD_PL_ASSEMBLE_FILE, data, packing)
end

def validate_file(md5, file_path)
    #define data bytes
    data = []
    data[0] = md5
    data[1] = file_path.length
    data[2] = file_path 
    packing = "C" + md5.length.to_s + "S>" + "a" + file_path.length.to_s

    #SM Send via UUT PAYLOAD_WRITE
    click_cmd(CMD_PL_VALIDATE_FILE, data, packing)
end

def move_file(source_file_path, destination_file_path)
    #define data bytes
    data = []
    data[0] = source_file_path.length
    data[1] = destination_file_path.length
    data[2] = source_file_path 
    data[3] = destination_file_path
    packing = "S>2" + "a" + source_file_path.length.to_s + "a" + destination_file_path.length.to_s

    #SM Send via UUT PAYLOAD_WRITE
    click_cmd(CMD_PL_MOVE_FILE, data, packing)
end

def delete_file(recursive, file_path)
    #define data bytes
    data = []
    data[0] = recursive
    data[1] = file_path.length
    data[2] = file_path 
    packing = "CS>" + "a" + file_path.length.to_s

    #SM Send via UUT PAYLOAD_WRITE
    click_cmd(CMD_PL_DEL_FILE, data, packing)
end

###################### Uplink File Information (Number of chunks, file length) #################################

# # User input dialog for file selection 
# selected_file = open_file_dialog()
# file_data = ""
# File.open(selected_file, 'rb') {|file| file_data = file.read()}

# # Filter will initially show only .txt files, but can be changed to show all files...
# # selected_file = open_file_dialog(Cosmos::USERPATH, "Open File", "Text (*.txt);;All (*.*)")

# Cosmos directory on the ground station computer
cosmos_dir = "C:/BCT/71sw0078_a_cosmos_click_edu"
sub_path_to_file = "/procedures/test/"

#define file name 
file_name = "test_file.txt"

#define destination file path
destination_file_path = "/root/" + file_name 

#define local file path:
local_file_path = cosmos_dir + sub_path_to_file + file_name 

#define chunk size parameter
chunk_size_bytes = 927 #ref: https://docs.google.com/spreadsheets/d/1ITNdvtceonKRpWd4pGuhg9Do2ZygTLGonbsYKwVzycM/edit#gid=1522568728 

# Open the uplink file and get content information
full_file = File.open(local_file_path, "rb")
fullfile_contents = full_file.read.bytes

# Check the length of the file
fullfile_length = fullfile_contents.length
puts "full file length: #{fullfile_length}"

# Calculate the number of chunks (file length divided by chunk size)
num_chunks = (fullfile_length/chunk_size_bytes.to_f).ceil
puts("num chunks: #{num_chunks}")

###################### Transfer ID Information ###############################
# Make sure that the file C:\BCT\71sw0078_a_cosmos_click_edu\procedures\trans_id.csv exists to track the transfer ID numbers used

# Read the last transfer ID sent and add 1 to it
last_trans_id = File.open("#{cosmos_dir}/procedures/trans_id.csv",'r'){|f| f.readlines[-1]}
print("\nlast trans id: #{last_trans_id.to_i}\n")

trans_id = last_trans_id.to_i+1 # increment the transfer ID
print ("new trans id: #{trans_id}\n")
trans_id = trans_id % (2**16) # mod 65536- transfer ID goes from 0 to 65535

# Add the new transfer ID to the file, along with the name of the file you sent (to keep track of file uploads attempted)
File.open("#{cosmos_dir}/procedures/trans_id.csv", 'a+') {|f| f.write("#{trans_id}, #{file_name}\n")}

# set the transfer ID number and name the directory/files
chunk_name = trans_id.to_i #file_name.split(".")[0].split("/")[-1]
puts chunk_name

#make a new folder in the outputs_data_uplink folder for the file chunks
FileUtils.mkdir_p "#{cosmos_dir}/outputs/data/uplink/#{chunk_name}"
dir = "#{cosmos_dir}/outputs/data/uplink/#{chunk_name}/"

# Calculate the MD5 Hash and put in a file in the directory to read later and compare
md5 = Digest::MD5.file file_name
puts "MD5: #{md5}"
File.open(dir + "MD5.txt", 'w'){|f| f.write(md5)}

prompt("Computed File Transfer Information.")

#TODO: Get housekeeping telemetry...
############# Listen for File Uplink Report Telemetry (not currently operational) ################
#~id = subscribe_packet_data([['UUT', 'PL_FILE_UPLNK_RPT']], 10000)

########################## Chunking ##################################
## CHUNK DATA into .chk files: 
#iterate over data and split into .chk binary files
i = 0
# For all of the full chunks, add the contents
while i<num_chunks - 1 do 
	chunk_contents = fullfile_contents[i*chunk_size_bytes..(i+1)*chunk_size_bytes-1]
	puts "chunk contents length: #{chunk_contents.length}" #, contents: #{chunk_contents}"
	chunk_filename = dir + "#{chunk_name}_#{i}.chk"
	puts "chunk filename: #{chunk_filename}"
	chunk_file = File.open(chunk_filename, 'wb') {|f| f.write(chunk_contents.pack('C*'))}
          puts chunk_contents.length
	i+=1
end 

#put rest of file in last chunk: 
chunk_contents = fullfile_contents[i*chunk_size_bytes..-1]
puts "last chunk length: #{chunk_contents.length}" #, contents: #{chunk_contents}"
chunk_filename = dir + "#{chunk_name}_#{i}.chk"
puts "chunk filename: #{chunk_filename}"
chunk_file = File.open(chunk_filename, 'wb') {|f| f.write(chunk_contents.pack('C*'))}

# retrieve list of chunks to uplink: 
filelist =  Dir[dir + "#{chunk_name}*.chk"].sort
print filelist

# stage chunks and properties for uplink: 
total_packets = filelist.length

prompt("Local File Chunking Complete. Press Continue to send all chunks.")

# Send the file chunks
file_seq_num = 0 
while file_seq_num < num_chunks do
    # Prepare the contents for uplink
    chunk_filename = dir + "#{chunk_name}_#{i}.chk" #define the chunk filename starting with chunk 0
    chunk_file = File.open(chunk_filename, "rb") #open the chunk file
    chunk_file_contents = chunk_file.read.bytes #read the chunk file contents
    chunk_file_length = chunk_file_contents.length #measure the length of the chunk file
    print("chunk file contents length: #{chunk_file_length}\n")
    send_file_chunk(trans_id, file_seq_num, num_chunks, chunk_file_length, chunk_file_contents)
    file_seq_num += 1 #increment file sequence number
end 
full_file.close

prompt("All Chunks Sent. Press Continue to assemble remote file in staging: " + payload_file_path_staging)
### Assemble File
#define payload file path:
staging_directory_path = '/root/file_staging/'+str(trans_id)
payload_file_path_staging = staging_directory_path + '/' + file_name 
assemble_file(trans_id, payload_file_path_staging)
#TODO: get telemetry

prompt("File assembled in staging. Press Continue to validate.")
### Validate File
validate_file(md5, payload_file_path_staging)

prompt("File validated in staging. Press Continue to move file from staging to final destination: " + destination_file_path)
### Move File
move_file(payload_file_path_staging, destination_file_path)

prompt("File moved to final destination. Press Continue to delete staging directory: " + staging_directory_path)
### Delete staging directory
delete_file(0xFF, staging_directory_path)

# Send the command twice for each packet (TBR) 
#sendAgain = 'yes' #leave this as 'yes' to automatically send the chunk twice
#singleChkSentCnt = 0 
# while sendAgain=='yes' do
    # send_file_chunk(trans_id, num_chunks, i, payload_file_path, payload_length, file_contents) 
    # singleChkSentCnt += 1
#     if singleChkSentCnt==1 then
#         send_file_chunk(trans_id, num_chunks, i, payload_file_path, payload_length, file_contents)
#         singleChkSentCnt += 1
#     end
#     sendAgain = 'no'
#     if num_chunks==1 then
#         sendAgain = message_box("Would you like to resend command?", 'yes', 'no')
#     end
# end

#~# Loop to check the queue for received file uplink reports (not yet operational)  
#~      wait(5) 
#~      100.times do    
#~      while @packet_data_queues.length > 0
#~        packet = get_packet(id)
#~        recorded_transfer_id = packet.read("TRANSF_ID")
#~        if recorded_transfer_id == trans_id
#~          recorded_segment_id = packet.read("SEG_ID")
#~        puts " transfer id: #{recorded_transfer_id}, segment id: #{recorded_segment_id}"
#~        break if recorded_segment_id = 65635
#~      end
#~      puts get_packet(id)
#~      report.each do
#~        recorded_trans_id = report.read("TRANSF_ID")
#~        if recorded_trans_id == trans_id
#~          recorded_segment_id = report.read("SEG_ID")
#~          if recorded_segment_id == 65535
#~            again = 'yes'
#~            puts "File Uplink Complete"
#~          end
#~        end
#~        puts " transfer id: #{trans_id}, segment id: #{segment_id}"
#~      end

# if file_seq_num == num_chunks  
#     again = message_box("File send complete, check the PL_FILE_UPLINK_RPT packet viewer. If SEG_ID field is not 0xFFFF, you should send the file again. Send again?", 'yes', 'no')
#     if again == 'yes'
#       i = 0
#     end
# end