#Test Script - Uplink File to Payload 
#Note: this, like scp in Linux, will overwrite a pre-existing file with the same path on the payload
#Assumed Path: #Cosmos::USERPATH + \procedures\CLICK-A-GSE\test\test_upload_file.rb

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
load (Cosmos::USERPATH + '/procedures/CLICK-A-GSE/lib/click_cmd_tlm.rb')

tlm_id_PL_ASSEMBLE_FILE = subscribe_packet_data([['UUT', 'PL_ASSEMBLE_FILE']], 10000) #set queue depth to 10000 (default is 1000)

def send_file_chunk(transfer_id, chunk_sequence_number, number_of_chunks_total, chunk_data_length, chunk_data)
    #define data bytes
    data = []
    data[0] = transfer_id
    data[1] = chunk_sequence_number
    data[2] = number_of_chunks_total 
    data[3] = chunk_data_length
    data += chunk_data
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
    md5_bytes = md5.digest.bytes
    data = []
    data += md5_bytes
    data += [file_path.length]
    data += [file_path]
    packing = "C" + md5_bytes.length.to_s + "S>" + "a" + file_path.length.to_s

    #SM Send via UUT PAYLOAD_WRITE
    click_cmd(CMD_PL_VALIDATE_FILE, data, packing)
end

###################### Uplink File Information (Number of chunks, file length) #################################

# # User input dialog for file selection 
# selected_file = open_file_dialog()
# file_data = ""
# File.open(selected_file, 'rb') {|file| file_data = file.read()}

# # Filter will initially show only .txt files, but can be changed to show all files...
# # selected_file = open_file_dialog(Cosmos::USERPATH, "Open File", "Text (*.txt);;All (*.*)")

# Cosmos directory on the ground station computer
cosmos_dir = Cosmos::USERPATH
sub_path_to_file = "/procedures/CLICK-A-GSE/test/"

#define file name 
file_name = "test_file_transfer.txt"

#define destination file path
destination_file_path = "/root/test/" + file_name 

#define local file path:
local_file_path = cosmos_dir + sub_path_to_file + file_name 

#define chunk size parameter (PL_UPLOAD_FILE packet def)
chunk_size_bytes = 927 #ref: https://docs.google.com/spreadsheets/d/1ITNdvtceonKRpWd4pGuhg9Do2ZygTLGonbsYKwVzycM/edit#gid=1522568728 

# Open the uplink file and get content information
full_file = File.open(local_file_path, "rb")
fullfile_contents = full_file.read.bytes

# Check the length of the file
fullfile_length = fullfile_contents.length
puts "full file length: #{fullfile_length}"

# Calculate the number of chunks (file length divided by chunk size)
num_chunks = (fullfile_length/chunk_size_bytes.to_f).ceil
puts "num chunks: #{num_chunks}"

###################### Transfer ID Information ###############################
# Make sure that the file C:\BCT\71sw0078_a_cosmos_click_edu\procedures\trans_id_ul.csv exists to track the transfer ID numbers used

# Read the last transfer ID sent and add 1 to it
last_trans_id = File.open("#{cosmos_dir}/procedures/CLICK-A-GSE/test/trans_id_ul.csv",'r'){|f| f.readlines[-1]}
puts "\nlast trans id: #{last_trans_id.to_i}\n"

trans_id = last_trans_id.to_i+1 # increment the transfer ID
puts "new trans id: #{trans_id}\n"
trans_id = trans_id % (2**16) # mod 65536- transfer ID goes from 0 to 65535

# Add the new transfer ID to the file, along with the name of the file you sent (to keep track of file uploads attempted)
File.open("#{cosmos_dir}/procedures/CLICK-A-GSE/test/trans_id_ul.csv", 'a+') {|f| f.write("#{trans_id}, #{file_name}\n")}

# set the transfer ID number and name the directory/files
chunk_name = trans_id.to_i #file_name.split(".")[0].split("/")[-1]
puts chunk_name

#make a new folder in the outputs_data_uplink folder for the file chunks
FileUtils.mkdir_p "#{cosmos_dir}/outputs/data/uplink/#{chunk_name}"
dir = "#{cosmos_dir}/outputs/data/uplink/#{chunk_name}/"

# Calculate the MD5 Hash and put in a file in the directory to read later and compare
md5 = Digest::MD5.file local_file_path
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
file_seq_num = 1
while file_seq_num <= num_chunks do
    # Prepare the contents for uplink
    chunk_filename = dir + "#{chunk_name}_#{file_seq_num}.chk" #define the chunk filename starting with chunk 0
    chunk_file = File.open(chunk_filename, "rb") #open the chunk file
    chunk_file_contents = chunk_file.read.bytes #read the chunk file contents
    chunk_file_length = chunk_file_contents.length #measure the length of the chunk file
    print("chunk file contents length: #{chunk_file_length}\n")
    send_file_chunk(trans_id, file_seq_num, num_chunks, chunk_file_length, chunk_file_contents)
    file_seq_num += 1 #increment file sequence number
end 
full_file.close

### Assemble File
#define payload file path:
staging_directory_path = '/root/file_staging/'+ trans_id.to_s
payload_file_path_staging = staging_directory_path + '/' + file_name 
prompt("All Chunks Sent. Press Continue to assemble remote file in staging: " + payload_file_path_staging)
assemble_file(trans_id, payload_file_path_staging)
#Get telemetry packet:
packet = get_packet(tlm_id_PL_ASSEMBLE_FILE)   

#Parse CCSDS header:             
_, _, _, pl_ccsds_apid, _, _, pl_ccsds_length =  parse_ccsds(packet) 
apid_check_bool = pl_ccsds_apid == TLM_ASSEMBLE_FILE

#Get assembly data
trans_id_rx = packet.read('TRANSFER_ID') 
trans_id_bool = trans_id == trans_id_rx
if !trans_id_bool
    puts "Transfer ID Error! Transmitted ID: " + trans_id.to_s + ". Received ID: " + trans_id_rx.to_s + ".\n"
end
status = packet.read('STATUS')
missing_packets_num = packet.read('MISSING_PACKETS_NUM')

#get missing packet ids (if any) and crc
missing_packets_check_bool = missing_packets_num == 0
if !missing_packets_check_bool
    packing = "S>" + missing_packets_num.to_s + "S>" #define data packing for variable length data
    missing_packet_ids, crc_rx = parse_variable_data_and_crc(packet, packing) #parse variable length data and crc
else
    crc_rx = parse_empty_data_and_crc(packet) #parse crc
end
crc_check_bool, crc_check = check_pl_tlm_crc(packet, crc_rx) #check CRC

error_message = ""
if !apid_check_bool
    error_message += "CCSDS APID Error! Received APID (= " + pl_ccsds_apid.to_s + ") not equal to TLM_ASSEMBLE_FILE APID (= " + TLM_ASSEMBLE_FILE.to_s + ").\n"
end
if !crc_check_bool
    error_message += "CRC Error! Received CRC (= " + crc_rx.to_s + ") not equal to expected CRC (= " + crc_check.to_s + ").\n"
end
status_check_bool = status == FL_SUCCESS
if status_check_bool
    if status == FL_ERR_EMPTY_DIR
        error_message += "Assembly Error! Empty directory. \n"
    elsif status == FL_ERR_FILE_NAME
        error_message += "Assembly Error! Chunk file name is not correct \n"
    elsif status == FL_ERR_SEQ_LEN
        error_message += "Assembly Error! Sequence length doesn't match. \n"
    elsif status == FL_ERR_MISSING_CHUNK
        error_message += "Assembly Error! Missing chunks. \n"
    else
        error_message += "Assembly Error! Unrecognized status = " + status.to_s 
    end
end

if !missing_packets_check_bool
    for i in 1..missing_packets_num
        error_message += "Missing Packet Error! Packet ID: " + missing_packet_ids.to_s + "\n"
    end
end

success_bool = apid_check_bool and crc_check and status_check_bool and missing_packets_check_bool
if success_bool
    prompt("File assembled in staging without errors. Press Continue to validate.")
    ### Validate File
    validate_file(md5, payload_file_path_staging)

    prompt("File validated in staging. Press Continue to move file from staging to final destination: " + destination_file_path)
    ### Move File
    move_file(payload_file_path_staging, destination_file_path)

    prompt("File moved to final destination. Press Continue to delete staging directory: " + staging_directory_path)
    ### Delete staging directory
    delete_file(0xFF, staging_directory_path)
else
    prompt("File assembly produced errors:\n" + error_message)
end

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