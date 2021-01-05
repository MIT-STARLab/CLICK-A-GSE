########################## File Uplink ##############################################
## Script to take a file, chunk it, stage for uplink, and uplink the file to the payload
## Written by Rachel Morgan and Jenny Gubner
## Last edited 5/20/20 by Jenny Gubner

# Still need to implement logic for:
    # PL not receiving first packet
    # MD5 Hash not matching but 0xFFFF received

# Specify what packages the script needs
require 'FileUtils' # Pretty sure COSMOS already requires this, so this is might be unnecessary
require 'digest/md5'

###################### Uplink File Information (Number of chunks, file length) #################################
# Cosmos directory on the ground station computer
cosmos_dir = "C:/BCT/37sw4455_c_cosmos_demi"

# File to be uploaded to DeMi (either specify the file name hardcoded in the script or allow a popup window to ask
filename = "C:/Users/STAR_User/Downloads/practice_file.txt" 
#filename = ask("Enter the file path name you'd like to stage (ie C:/Users/STAR_User/Desktop/Data.fits")

# Choose which pi to send the file to
# pi_cmd = message_box("Which pi would you like to command? Pi 2 is Payload 1, Pi 3 is Payload 2.", 'PI_2', 'PI_3')

chunk_size_bytes = 900 #max size of a .chk file to put in packet

# Open the uplink file and get content information
full_file = File.open(filename, "rb")
fullfile_contents = full_file.read.bytes

# Check the length of the file
fullfile_length = fullfile_contents.length
puts "full file length: #{fullfile_length}"

# Calculate the number of chunks (file length divided by chunk size)
num_chunks = (fullfile_length/chunk_size_bytes.to_f).ceil
puts("num chunks: #{num_chunks}")


###################### Transfer ID Information ###############################
# Make sure that the file "C:/BCT/37sw4455_c_cosmos_demi/procedures/trans_id.csv" exists to track the transfer ID numbers used

# Read the last transfer ID sent and add 1 to it (all packets will start at 1 )
last_trans_id = File.open("#{cosmos_dir}/procedures/trans_id.csv",'r'){|f| f.readlines[-1]}
print("\nlast trans id: #{last_trans_id.to_i}\n")

trans_id = last_trans_id.to_i+1 # increment the transfer ID
print ("new trans id: #{trans_id}\n")
trans_id = trans_id % (2**16) # mod 65536- transfer ID goes from 0 to 65535

# Add the new transfer ID to the file, along with the name of the file you sent (to keep track of file uploads attempted)
File.open("#{cosmos_dir}/procedures/trans_id.csv", 'a+') {|f| f.write("#{trans_id}, #{filename}\n")}

# set the transfer ID number and name the directory/files
chunk_name = trans_id.to_i #filename.split(".")[0].split("/")[-1]
puts chunk_name

#make a new folder in the outputs_data_uplink folder for the file chunks
FileUtils.mkdir_p "#{cosmos_dir}/outputs/data/uplink/#{chunk_name}"
dir = "#{cosmos_dir}/outputs/data/uplink/#{chunk_name}/"

# Calculate the MD5 Hash and put in a file in the directory to read later and compare
md5 = Digest::MD5.file filename
puts "MD5: #{md5}"
File.open(dir + "MD5.txt", 'w'){|f| f.write(md5)}

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
filelist =  Dir[ dir + "#{chunk_name}*.chk"].sort
print filelist

# stage chunks and properties for uplink: 
total_packets = filelist.length

i=0 
while i<num_chunks do
    # Prepare the contents for uplink
    chunk_filename = dir + "#{chunk_name}_#{i}.chk" #define the chunk filename starting with chunk 0
    file = File.open(chunk_filename, "rb") #open the chunk file
    file_contents = file.read.bytes #read the chunk file contents
    payload_length = file_contents.length #measure the length of the chunk file
    print("file contents length: #{payload_length}\n")
    sendAgain = 'yes' #leave this as 'yes' to automatically send the chunk twice
    singleChkSentCnt = 0
    
    # Send the command twice for each packet    
    while sendAgain=='yes' do
        #puts pi_cmd, trans_id, num_chunks,i, file_contents
        cmd("UUT PL_UPLOAD_FILE_TOSTAGING with TRANS_ID #{trans_id}, TOT_PACKETS_NUM #{num_chunks}, FILE_SEQ_NUM #{i}, PL_SIZE #{payload_length}, DATA #{file_contents}")
        singleChkSentCnt += 1
        if singleChkSentCnt==1 then
            cmd("UUT PL_UPLOAD_FILE_TOSTAGING with TRANS_ID #{trans_id}, TOT_PACKETS_NUM #{num_chunks}, FILE_SEQ_NUM #{i}, PL_SIZE #{payload_length}, DATA #{file_contents}")
            singleChkSentCnt += 1
        end
        sendAgain = 'no'
        if num_chunks==1 then
            sendAgain = message_box("Would you like to resend command?", 'yes', 'no')
        end
    end
    i+=1
    if i == num_chunks
    
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

      again = message_box("File send complete, check the PL_FILE_UPLINK_RPT packet viewer. If SEG_ID field is not 0xFFFF, you should send the file again. Send again?", 'yes', 'no')
      if again == 'yes'
        i = 0
      end
    end
end 
full_file.close