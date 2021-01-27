#Library for CLICK A payload command and telemetry 
#Assumed Path: #C:\BCT\71sw0078_a_cosmos_click_edu\procedures\lib\click_cmd_tlm.rb

load 'C:/BCT/71sw0078_a_cosmos_click_edu/procedures/lib/pl_cmd_tlm_apids.rb'
load 'C:/BCT/71sw0078_a_cosmos_click_edu/procedures/lib/crc16.rb'

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
    pl_var_data = pl_data_and_crc_list[0] #get data from list
    crc = pl_data_and_crc_list[1] #get crc from list
    return pl_var_data, crc 
end

### Check CRC received in payload telemetry packet
def check_pl_tlm_crc(packet, crc_rx)
    #Check the CRC:
    packet_data_bytes = packet.buffer[COSMOS_HEADER_LENGTH..(packet.buffer.length-CRC_LEN-1)] #get crc calculation argument: CCSDS header + data
    crc_check = Crc16.new.update(packet_data_bytes.unpack("C*"))  
    crc_check_bool = crc_rx == crc_check
    return crc_check_bool, crc_check
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
    if !crc_check_bool
        error_message += "CRC Error! Received CRC (= " + crc_rx.to_s + ") not equal to expected CRC (= " + crc_check.to_s + "). "
    end
    if !echo_data_check_bool
        error_message += "Echo Data Error! Transmitted Data: " + echo_data_tx + ". Received data: " + echo_data_rx + ". "
    end

    return success_bool, error_message
end