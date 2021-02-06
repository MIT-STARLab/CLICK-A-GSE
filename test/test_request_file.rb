#Test Script - Request Payload File Downlink
#Assumed Path: #Cosmos::USERPATH + \procedures\CLICK-A-GSE\test\test_request_file.rb

require 'FileUtils' # Pretty sure COSMOS already requires this, so this is might be unnecessary
require 'digest/md5'
load (Cosmos::USERPATH + '/procedures/CLICK-A-GSE/lib/click_cmd_tlm.rb')
cosmos_dir = Cosmos::USERPATH

def download_chunk(chunk_seq_num, trans_id, save_dir, tlm_id_PL_DL_FILE)
        #Get telemetry packet:
        packet = get_packet(tlm_id_PL_DL_FILE)   

        #Parse CCSDS header:             
        _, _, _, pl_ccsds_apid, _, _, _ =  parse_ccsds(packet) 
        apid_check_bool = pl_ccsds_apid == TLM_DL_FILE
    
        #Get chunk data
        trans_id_rx = packet.read('TRANSFER_ID')
        trans_id_bool = trans_id_rx == trans_id 
    
        md5_rx_bytes = packet.read('FILE_MD5')
    
        chunk_seq_num_rx = packet.read('CHUNK_SEQ_NUM')
        chunk_seq_num_bool = chunk_seq_num == chunk_seq_num_rx
        chunk_total_count = packet.read('CHUNK_TOTAL_COUNT')
    
        #Read the data bytes and check CRC:
        chunk_data_length = packet.read('CHUNK_DATA_LENGTH')
        packing = "a" + chunk_data_length.to_s + "S>" #define data packing for telemetry packet
        chunk_data, crc_rx = parse_variable_data_and_crc(packet, packing) #parse variable length data and crc
        crc_check_bool, crc_check = check_pl_tlm_crc(packet, crc_rx) #check CRC
    
        #Save data
        chunk_filename = save_dir + "#{trans_id}_#{chunk_seq_num_rx}.chk"
        puts "chunk filename: #{chunk_filename}"
        chunk_file = File.open(chunk_filename, 'wb') {|f| f.write(chunk_data)}

        chunk_error_message = ""
        #Error messages
        if !apid_check_bool
            chunk_error_message += "[CHUNK " + chunk_seq_num_rx.to_s + "] CCSDS APID Error! Received APID (= " + pl_ccsds_apid.to_s + ") not equal to TLM_DL_FILE APID (= " + TLM_DL_FILE.to_s + ").\n"
        end
        if !crc_check_bool
            chunk_error_message += "[CHUNK " + chunk_seq_num_rx.to_s + "] CRC Error! Received CRC (= " + crc_rx.to_s + ") not equal to expected CRC (= " + crc_check.to_s + ").\n"
        end
        if !trans_id_bool
            chunk_error_message += "[CHUNK " + chunk_seq_num_rx.to_s + "] Transfer ID Error! Transmitted ID: " + trans_id.to_s + ". Received ID: " + trans_id_rx.to_s + ".\n"
        end
        #TODO md5 hash error
        if !chunk_seq_num_bool
            chunk_error_message += "[CHUNK " + chunk_seq_num_rx.to_s + "] Chunk Sequence Error! Expected Chunk Number: " + chunk_seq_num.to_s + ". Received Chunk Number: " + chunk_seq_num_rx.to_s + ".\n"
        end
        return chunk_error_message, chunk_total_count, md5_rx_bytes
end

tlm_id_PL_DL_FILE = subscribe_packet_data([['UUT', 'PL_DL_FILE']], 10000) #set queue depth to 10000 (default is 1000)

#define file path:
remote_directory = "/root/test/"
file_name = "test_tlm.txt"
file_path = remote_directory + file_name #can get image name via list file command or via housekeeping tlm stream or PAT .txt telemetry file

#define chunk size parameter (PL_DL_FILE packet def)
chunk_size_bytes = 4047 #ref: https://docs.google.com/spreadsheets/d/1ITNdvtceonKRpWd4pGuhg9Do2ZygTLGonbsYKwVzycM/edit#gid=1522568728 

# Read the last transfer ID and add 1 to it
last_trans_id = File.open("#{cosmos_dir}/procedures/CLICK-A-GSE/test/trans_id_dl.csv",'r'){|f| f.readlines[-1]}
print("\nlast trans id: #{last_trans_id.to_i}\n")

trans_id = last_trans_id.to_i+1 # increment the transfer ID
print ("new trans id: #{trans_id}\n")
trans_id = trans_id % (2**16) # mod 65536- transfer ID goes from 0 to 65535

# Add the new transfer ID to the file, along with the name of the file you sent (to keep track of file uploads/downloads attempted)
File.open("#{cosmos_dir}/procedures/CLICK-A-GSE/test/trans_id_dl.csv", 'a+') {|f| f.write("#{trans_id}, #{file_path}\n")}

#make a new folder in the outputs/data/downlink folder for the file chunks
FileUtils.mkdir_p "#{cosmos_dir}/outputs/data/downlink/#{trans_id}"
save_dir = "#{cosmos_dir}/outputs/data/downlink/#{trans_id}/"

#define data bytes
data = []
data[0] = trans_id
data[1] = chunk_size_bytes
data[2] = file_path.length
data[3] = file_path 
packing = "S>3" + "a" + file_path.length.to_s

#SM Send via UUT PAYLOAD_WRITE
click_cmd(CMD_PL_REQUEST_FILE, data, packing)

#Get File Chunks
download_complete = false
error_message = ""
chunk_seq_num = 0
while !download_complete
    chunk_seq_num += 1
    chunk_error_message, chunk_total_count, md5_rx_bytes = download_chunk(chunk_seq_num, trans_id, save_dir, tlm_id_PL_DL_FILE)
    if chunk_error_message.length > 0
        puts chunk_error_message 
        error_message += chunk_error_message
    end
    download_complete = chunk_seq_num == chunk_total_count #TODO: put a timer on this in case the last chunk packet never arrives
end

if error_message.length == 0
    prompt("Chunk download complete with no errors. Press Okay to proceed to file assembly.")
    assemble_cmd = 'YES'
else
    assemble_cmd = message_box("Chunk download complete with errors: \n" + error_message + "Proceed to file assembly?", 'YES', 'NO')
end

if assemble_cmd == 'YES'
    ## Re-assemble file...
            
    # input the filename you want to chunk together: 
    reconstructed_filename = save_dir + file_name
    puts reconstructed_filename

    ## put file back together based on chunks in chunks folder: 
    seq_num=1
    File.open(reconstructed_filename, 'wb') {|f| 
    while seq_num<=chunk_total_count do
      chunk_filename = save_dir + trans_id.to_s + "_" + seq_num.to_s + ".chk"
      file = File.open("#{chunk_filename}", "rb")
      chunk_contents = file.read
      puts "chunk contents: ", chunk_contents
      f.write(chunk_contents)
      seq_num+=1
    end 
    }

    #check md5 hash
    md5 = Digest::MD5.file reconstructed_filename
    md5_bytes = md5.digest.bytes
    if md5_bytes != md5_rx_bytes
      prompt('ERROR: Calculated MD5 hash does not match received MD5 hash.')
      puts "md5 bytes calculated: ", md5_bytes
      puts "md5 bytes received: ", md5_rx_bytes
    end
end
