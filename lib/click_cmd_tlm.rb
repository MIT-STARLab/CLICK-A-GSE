#Library for CLICK A payload command and telemetry 
#Assumed Path: #Cosmos::USERPATH + \procedures\CLICK-A-GSE\lib\crc16.rb

require 'FileUtils' # Pretty sure COSMOS already requires this, so this is might be unnecessary
require 'digest/md5'

load (Cosmos::USERPATH + '/procedures/CLICK-A-GSE/lib/pl_cmd_tlm_apids.rb')
load (Cosmos::USERPATH + '/procedures/CLICK-A-GSE/lib/crc16.rb')

### Send command to payload via PAYLOAD_WRITE
def click_cmd(cmd_id, data = [], packing = "C*")
    #cmd_ids defined here: https://docs.google.com/spreadsheets/d/1ITNdvtceonKRpWd4pGuhg9Do2ZygTLGonbsYKwVzycM/edit#gid=1522568728
    #data_packed is a packed data set (e.g. [0x01,0x0200].pack("CS>")): https://www.rubydoc.info/stdlib/core/1.9.3/Array:pack 
    
    #pack data into binary sequence
    data_packed = data.pack(packing) 

    #get packet length (secondary header + data bytes + crc - 1)
    packet_length = data_packed.length + SECONDARY_HEADER_LEN + CRC_LEN - 1

    #get time stamp
    utc_time = Time.now.utc.to_f
    utc_time_sec = utc_time.floor #uint32
    utc_time_subsec = (5*(utc_time - utc_time_sec)).round #= ((1000*frac)/200).round

    #construct CCSDS header (primary and secondary)
    header = []
    header[IDX_CCSDS_VER] = CCSDS_VER | (cmd_id >> 8) #TBR
    header[IDX_CCSDS_APID] = cmd_id & 0xFF #TBR
    header[IDX_CCSDS_GRP] = CCSDS_GRP_NONE #TBR
    header[IDX_CCSDS_SEQ] = 0 #TBR
    header[IDX_CCSDS_LEN] = packet_length 
    header[IDX_TIME_SEC] = utc_time_sec
    header[IDX_TIME_SUBSEC] = utc_time_subsec
    header[IDX_RESERVED] = 0
    packing_header = "C4S>L>C2"   
    header_packed = header.pack(packing_header) 

    #compute CRC16 and append to packet
    packet_packed = header_packed + data_packed
    crc = Crc16.new.update(packet_packed.unpack("C*"))
    packet_packed += [crc].pack("S>")
  
    #send PAYLOAD_WRITE command
    raw_bytes = packet_packed.unpack("C*")
    cmd("UUT PAYLOAD_WRITE with RAW_BYTES #{raw_bytes}, LENGTH #{raw_bytes.length}")
end

### Get timestamp for file saving
def get_timestamp()
    current_time = Time.now #time of test start
    current_time_str = current_time.to_s #human readable time
    current_timestamp = current_time.to_f.floor.to_s #timestamp in seconds
    return current_timestamp, current_time_str
end

### Parse CCSDS header in payload telemetry packet
def parse_ccsds(packet)
    #Read the packet CCSDS primary header:
    pl_ccsds_ver = packet.read('PL_CCSDS_VER')
    pl_ccsds_type = packet.read('PL_CCSDS_TYPE')
    pl_ccsds_secondary = packet.read('PL_CCSDS_SECNDRY')
    pl_ccsds_apid = packet.read('PL_CCSDS_APID') #should be equal to TLM_ECHO
    pl_ccsds_group = packet.read('PL_CCSDS_GRP')
    pl_ccsds_sequence = packet.read('PL_CCSDS_SEQ')
    pl_ccsds_length = packet.read('PL_CCSDS_LEN')
    return pl_ccsds_ver, pl_ccsds_type, pl_ccsds_secondary, pl_ccsds_apid, pl_ccsds_group, pl_ccsds_sequence, pl_ccsds_length
end

### Parse variable length data and crc in payload telemetry packet
def parse_variable_data_and_crc(packet, packing)
    #Read the data bytes:
    pl_data_and_crc_bytes = packet.read('PL_VAR_DATA_AND_CRC')
    pl_data_and_crc_packed = pl_data_and_crc_bytes.pack("C*") #convert to packed string
    pl_data_and_crc_list = pl_data_and_crc_packed.unpack(packing) #unpack data to list
    pl_data_end_idx = pl_data_and_crc_list.length - 2
    if pl_data_end_idx > 0
      pl_var_data = pl_data_and_crc_list[0..pl_data_end_idx] #get data from list
      crc = pl_data_and_crc_list[pl_data_and_crc_list.length - 1] #get crc from list
    else
      pl_var_data = pl_data_and_crc_list[0] #get data from list
      crc = pl_data_and_crc_list[1] #get crc from list
    end
    
    return pl_var_data, crc 
end

### Parse variable length data and crc in payload telemetry packet
def parse_empty_data_and_crc(packet)
    #Read the data bytes:
    pl_data_and_crc_bytes = packet.read('PL_VAR_DATA_AND_CRC')
    pl_data_and_crc_packed = pl_data_and_crc_bytes.pack("C*") #convert to packed string
    pl_data_and_crc_list = pl_data_and_crc_packed.unpack("S>") #unpack data to list
    crc = pl_data_and_crc_list[0] #get crc from list
    return crc 
end

### Check CRC received in payload telemetry packet
def check_pl_tlm_crc(packet, crc_rx)
    #Check the CRC:
    packet_data_bytes = packet.buffer[COSMOS_HEADER_LENGTH..(packet.buffer.length-CRC_LEN-1)] #get crc calculation argument: CCSDS header + data
    crc_check = Crc16.new.update(packet_data_bytes.unpack("C*"))  
    crc_check_bool = crc_rx == crc_check
    return crc_check_bool, crc_check
end

### Move file command
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

### Delete file command
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

### List file command
def list_file(directory_path, tlm_id_PL_LIST_FILE)
    #define data bytes
    data = []
    data[0] = directory_path.length
    data[1] = directory_path 
    packing = "S>" + "a" + directory_path.length.to_s

    #SM Send via UUT PAYLOAD_WRITE
    click_cmd(CMD_PL_LIST_FILE, data, packing)

    #Get telemetry packet:
    packet = get_packet(tlm_id_PL_LIST_FILE)   

    #Parse CCSDS header:             
    _, _, _, pl_ccsds_apid, _, _, pl_ccsds_length =  parse_ccsds(packet) 
    apid_check_bool = pl_ccsds_apid == TLM_LIST_FILE
    
    #Define variable length data packing:
    list_file_data_length = pl_ccsds_length - CRC_LEN + 1 #get data size
    packing = "a" + list_file_data_length.to_s + "S>" #define data packing for telemetry packet

    #Read the data bytes and check CRC:
    list_file_data, crc_rx = parse_variable_data_and_crc(packet, packing) #parse variable length data and crc
    crc_check_bool, crc_check = check_pl_tlm_crc(packet, crc_rx) #check CRC

    success_bool = apid_check_bool and crc_check_bool

    error_message = ""
    if !apid_check_bool
        error_message += "CCSDS APID Error! Received APID (= " + pl_ccsds_apid.to_s + ") not equal to PL_LIST_FILE APID (= " + TLM_ECHO.to_s + ").\n"
    end
    if !crc_check_bool
        error_message += "CRC Error! Received CRC (= " + crc_rx.to_s + ") not equal to expected CRC (= " + crc_check.to_s + ").\n"
    end

    return  success_bool, list_file_data, error_message
end

### Echo test function
def echo_test(echo_data_tx, tlm_id_PL_ECHO)
    #define data bytes
    data = []
    data[0] = echo_data_tx
    packing = "a" + echo_data_tx.length.to_s

    #SM Send via UUT PAYLOAD_WRITE
    click_cmd(CMD_PL_ECHO, data, packing)

    #Get telemetry packet:
    packet = get_packet(tlm_id_PL_ECHO)   

    #Parse CCSDS header:             
    _, _, _, pl_ccsds_apid, _, _, pl_ccsds_length =  parse_ccsds(packet) 
    apid_check_bool = pl_ccsds_apid == TLM_ECHO
    
    #Define variable length data packing:
    echo_data_rx_length = pl_ccsds_length - CRC_LEN + 1 #get data size
    packing = "a" + echo_data_rx_length.to_s + "S>" #define data packing for telemetry packet

    #Read the data bytes and check CRC:
    echo_data_rx, crc_rx = parse_variable_data_and_crc(packet, packing) #parse variable length data and crc
    crc_check_bool, crc_check = check_pl_tlm_crc(packet, crc_rx) #check CRC
    echo_data_check_bool = echo_data_rx == echo_data_tx #check echo data
    
    #Determine if echo was successful and if not, generate error message:
    success_bool = apid_check_bool and crc_check_bool and echo_data_check_bool
    error_message = ""
    if !apid_check_bool
        error_message += "CCSDS APID Error! Received APID (= " + pl_ccsds_apid.to_s + ") not equal to PL_ECHO APID (= " + TLM_ECHO.to_s + "). "
    end
    if !crc_check_bool
        error_message += "CRC Error! Received CRC (= " + crc_rx.to_s + ") not equal to expected CRC (= " + crc_check.to_s + "). "
    end
    if !echo_data_check_bool
        error_message += "Echo Data Error! Transmitted Data: " + echo_data_tx + ". Received data: " + echo_data_rx + ". "
    end

    return success_bool, error_message
end

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

def disassemble_file(trans_id, file_path)
    #define chunk size parameter (PL_DL_FILE packet def)
    chunk_size_bytes = 4047 #ref: https://docs.google.com/spreadsheets/d/1ITNdvtceonKRpWd4pGuhg9Do2ZygTLGonbsYKwVzycM/edit#gid=1522568728 

    #define data bytes
    data = []
    data[0] = trans_id
    data[1] = chunk_size_bytes
    data[2] = file_path.length
    data[3] = file_path 
    packing = "S>3" + "a" + file_path.length.to_s

    #SM Send via UUT PAYLOAD_WRITE
    click_cmd(CMD_PL_DISASSEMBLE_FILE, data, packing)
end

def request_file_chunks(trans_id, all_chunks_bool, chunk_start_idx = 0, num_chunks = 0)
    #define data bytes
    data = []
    data[0] = trans_id
    if all_chunks_bool
        data[1] = 0xFF
    else
        data[1] = 0x00
    end
    data[2] = chunk_start_idx
    data[3] = num_chunks 
    packing = "S>CS>2"

    #SM Send via UUT PAYLOAD_WRITE
    click_cmd(CMD_PL_REQUEST_FILE, data, packing)
end

def upload_file(tlm_id_PL_ASSEMBLE_FILE)
    ###################### Uplink File Information (Number of chunks, file length) #################################   
    # Cosmos directory on the ground station computer
    cosmos_dir = Cosmos::USERPATH

    #define local file path and file name
    local_file_path = open_file_dialog(Cosmos::USERPATH, "Open File", "All (*.*)")
    local_file_path_list = local_file_path.split("/")
    file_name = local_file_path_list[-1]

    #define destination file path
    destination_directory = ask_string("For file upload, input destination directory (e.g. /root/test/)")
    destination_file_path = destination_directory + file_name

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

    #make a new folder in the outputs_data_uplink folder for the file chunks
    FileUtils.mkdir_p "#{cosmos_dir}/outputs/data/uplink/#{trans_id}"
    dir = "#{cosmos_dir}/outputs/data/uplink/#{trans_id}/"

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
    seq_num = 1
    # For all of the full chunks, add the contents
    while seq_num < num_chunks do 
    chunk_contents = fullfile_contents[(seq_num-1)*chunk_size_bytes..seq_num*chunk_size_bytes-1]
    puts "chunk contents length: #{chunk_contents.length}" #, contents: #{chunk_contents}"
    chunk_filename = dir + "#{trans_id}_#{seq_num}.chk"
    puts "chunk filename: #{chunk_filename}"
    chunk_file = File.open(chunk_filename, 'wb') {|f| f.write(chunk_contents.pack('C*'))}
    puts chunk_contents.length
    seq_num += 1
    end 

    #put rest of file in last chunk: 
    chunk_contents = fullfile_contents[(seq_num-1)*chunk_size_bytes..-1]
    puts "last chunk length: #{chunk_contents.length}" #, contents: #{chunk_contents}"
    chunk_filename = dir + "#{trans_id}_#{seq_num}.chk"
    puts "chunk filename: #{chunk_filename}"
    chunk_file = File.open(chunk_filename, 'wb') {|f| f.write(chunk_contents.pack('C*'))}

    # retrieve list of chunks to uplink: 
    filelist =  Dir[dir + "#{trans_id}*.chk"].sort
    print filelist

    # stage chunks and properties for uplink: 
    total_packets = filelist.length

    prompt("Local File Chunking Complete. Press Continue to send all chunks.")

    # Send the file chunks
    file_seq_num = 1
    while file_seq_num <= num_chunks do
        # Prepare the contents for uplink
        chunk_filename = dir + "#{trans_id}_#{file_seq_num}.chk" #define the chunk filename starting with chunk 0
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
    error_message = ""
    if !trans_id_bool
        error_message += ("Transfer ID Error! Transmitted ID: " + trans_id.to_s + ". Received ID: " + trans_id_rx.to_s + ".\n")
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

    if !apid_check_bool
        error_message += ("CCSDS APID Error! Received APID (= " + pl_ccsds_apid.to_s + ") not equal to TLM_ASSEMBLE_FILE APID (= " + TLM_ASSEMBLE_FILE.to_s + ").\n")
    end
    if !crc_check_bool
        error_message += ("CRC Error! Received CRC (= " + crc_rx.to_s + ") not equal to expected CRC (= " + crc_check.to_s + ").\n")
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
            error_message += ("Assembly Error! Unrecognized status = " + status.to_s)
        end
    end

    if !missing_packets_check_bool
        for i in 1..missing_packets_num
            error_message += ("Missing Packet Error! Packet ID: " + missing_packet_ids.to_s + "\n")
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

end

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

def request_file(file_path, tlm_id_PL_DL_FILE, user_save_dir = "")
    cosmos_dir = Cosmos::USERPATH

    #define file name
    file_path_list = file_path.split("/")
    file_name = file_path_list[-1]
    
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
    click_cmd(CMD_PL_AUTO_DOWNLINK_FILE, data, packing)
    
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
        ## Re-assemble file...
        # input the filename you want to chunk together: 
        if(user_save_dir.length > 0)
            reconstructed_filename = user_save_dir + "/" + file_name
        else
            reconstructed_filename = save_dir + file_name
        end
    
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
            prompt('Error in file assembly: calculated MD5 hash does not match received MD5 hash.')
            puts "md5 bytes calculated: ", md5_bytes
            puts "md5 bytes received: ", md5_rx_bytes
        else 
            prompt("File assembly completed with no errors. File location: " + reconstructed_filename)
        end
    else
        prompt("Chunk download complete with errors: \n" + error_message)
    end
end

def request_directory_files(directory_path, tlm_id_PL_LIST_FILE, tlm_id_PL_DL_FILE)
    user_save_dir = open_directory_dialog(Cosmos::USERPATH, "Select Directory To Save Downloads To")
    success_bool, list_file_data, error_message = list_file(directory_path, tlm_id_PL_LIST_FILE)
    if(success_bool)
        directory_list = list_file_data.split("\n")
        if(directory_list.length > 0)
            for i in 0..(directory_list.length-1)
                file_name = directory_list[i]
                file_path = directory_path + "/" + file_name
                execute_cmd = message_box("Download this file?\n" + file_path, 'YES', 'NO')
                if execute_cmd == 'YES'
                    request_file(file_path, tlm_id_PL_DL_FILE, user_save_dir)  
                end
            end
        else
            prompt(directory_path + " is empty.")
        end
    else
        prompt(error_message + list_file_data)
    end
end

def request_pat_telemetry(tlm_id_PL_LIST_FILE, tlm_id_PL_DL_FILE, exp_num_str = "")
    if(exp_num_str.length == 0)
        #look up pat experiment number
        success_bool, list_file_data, error_message = list_file("/root/log/pat", tlm_id_PL_LIST_FILE)
        download_bool = false
        if(success_bool)
            directory_list = list_file_data.split("\n")
            if(directory_list.length > 0)
                exp_num = 1
                for i in 0..(directory_list.length-1)
                    exp_folder_num = directory_list[i].to_i
                    if(exp_folder_num > exp_num)
                        exp_num = exp_folder_num
                    end
                end
                exp_num_str = exp_num.to_s 
                exp_folder_path = "/root/log/pat/" + exp_num_str 
                prompt("Path to current PAT log directory is: " + exp_folder_path + "\nPress Continue to restart PAT and download log files.")
                download_bool = true
                #end pat (to terminate the log file; it will be restarted automatically by housekeeping)
                click_cmd(CMD_PL_END_PAT_PROCESS)
            else
                prompt("PAT log directory is empty.")
            end
        else
            prompt("Error in looking up PAT experiment number: " + error_message + list_file_data)
        end
    else
        exp_folder_path = "/root/log/pat/" + exp_num_str 
        prompt("Path to PAT log directory is: " + exp_folder_path + "\nPress Continue to download log files.")
        download_bool = true
    end

    if(download_bool)
        #download the experiment folder contents
        request_directory_files(exp_folder_path, tlm_id_PL_LIST_FILE, tlm_id_PL_DL_FILE)
    end
end