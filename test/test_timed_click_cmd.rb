#Test Sending Payload Write Echo Via Store Timed Command

#load (Cosmos::USERPATH + "/procedures/CLICK-A-GSE/lib/pl_cmd_tlm_apids.rb") #previous path
#load (Cosmos::USERPATH + "/procedures/CLICK-A-GSE/lib/crc16.rb") #previous path
load ('C:/CLICK-A-GSE/lib/pl_cmd_tlm_apids.rb') #new path - not sure why this was changed'
load ('C:/CLICK-A-GSE/lib/crc16.rb') #new path - not sure why this was changed'
load ('C:/CLICK-A-GSE/lib/click_cmd_tlm.rb')

tlm_id_PL_ECHO = subscribe_packet_data([['UUT', 'PL_ECHO']], 10000) #set queue depth to 10000 (default is 1000)

UTC_TAI_OFFSET = 37 #TAI is exactly 37 seconds ahead of UTC
#sync bus time for test
ref_tai_time_sec = Time.now.utc.to_f.floor + UTC_TAI_OFFSET
cmd("UUT SET_CURRENT_TIME_TAI with TIME #{ref_tai_time_sec}")

#get user data
user_echo_data = ask_string("For Test Store Timed Command - PL_ECHO, input string to echo.")

#get time stamp
curr_time = Time.now
utc_time = curr_time.utc.to_f
utc_time_sec = utc_time.floor #uint32
utc_time_subsec = (5*(utc_time - utc_time_sec)).round #= ((1000*frac)/200).round

#get execution time
user_delay_sec = ask("Current UTC time is: " + curr_time.to_s + "\nFor Test Store Timed Command - Input time to wait (in seconds) before execution.")
user_exec_time_tai_sec = utc_time_sec + UTC_TAI_OFFSET + user_delay_sec
user_exec_time_subsec = utc_time_subsec

#define data bytes
data = []
data[0] = user_echo_data
packing = "a" + user_echo_data.length.to_s
pl_cmd_apid = CMD_PL_ECHO

#pack data into binary sequence
data_packed = data.pack(packing) 

#get packet length (secondary header + data bytes + crc - 1)
packet_length = data_packed.length + SECONDARY_HEADER_LEN + CRC_LEN - 1

#construct CCSDS header (primary and secondary)
header = []
header[IDX_CCSDS_VER] = CCSDS_VER | (pl_cmd_apid >> 8) #TBR
header[IDX_CCSDS_APID] = pl_cmd_apid & 0xFF #TBR
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
raw_bytes_payload_write = packet_packed.unpack("C*")

#prepend PAYLOAD_WRITE header to packet
payload_write_header_packed = [15,3,raw_bytes_payload_write.length].pack("C2S>")
packed_packed_store_timed_command = payload_write_header_packed + packet_packed
raw_bytes_store_timed_command = packed_packed_store_timed_command.unpack("C*")

#Send timed command
cmd_id = 1 #arbitrary
cmd("UUT STORE_TIMED_COMMAND with CMD_ID #{cmd_id}, EXEC_TIME #{user_exec_time_tai_sec}, ADD_CYCLE #{user_exec_time_subsec}, LENGTH #{raw_bytes_store_timed_command.length}, RAW_BYTES #{raw_bytes_store_timed_command}")

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
echo_data_check_bool = echo_data_rx == user_echo_data #check echo data

#Verify packet and determine if echo was successful:
if apid_check_bool
    if crc_check_bool
        if echo_data_check_bool
            prompt("Successful Echo! Transmitted Data: " + user_echo_data + ". Received data: " + echo_data_rx) 
        else
            prompt("Echo Data Error! Transmitted Data: " + user_echo_data + ". Received data: " + echo_data_rx) 
        end
    else
        prompt("CRC Error! Received CRC (= " + crc_rx.to_s + ") not equal to expected CRC (= " + crc_check.to_s + ")")
    end
else
    prompt("CCSDS APID Error! Received APID (= " + pl_ccsds_apid.to_s + ") not equal to PL_ECHO APID (= " + TLM_ECHO.to_s + ")")
end

