#Test Script - Payload System Housekeeping Telemetry
#Assumed Path: #Cosmos::USERPATH + \procedures\CLICK-A-GSE\test\test_hk_sys_tlm.rb
load (Cosmos::USERPATH + '/procedures/CLICK-A-GSE/lib/click_cmd_tlm.rb')

#Subscribe to telemetry packets:
tlm_id_PL_HK_SYS = subscribe_packet_data([['UUT', 'PL_HK_SYS']], 500000) #set queue depth to 500000 (default is 1000)

#Save test results to text file:
current_timestamp, current_time_str = get_timestamp()
test_log_dir = (Cosmos::USERPATH + "/outputs/logs/xb1_click/")
file_name = "HK_SYS_" + current_timestamp + ".txt"
file_path = test_log_dir + file_name
File.open(file_path, 'a+') {|f| f.write("Housekeeping Telemetry - System Health. Start Time: " + current_time_str + "\n")}

hk_sys_pkt_fixed_data_fields = %w[
    CCSDS_TAI_SECS
    HK_SYS_COUNTER
    ENABLE_FLAGS
    HK_FPGA_PERIOD
    HK_SYS_PERIOD
    CH_HEARTBEAT_PERIOD
    PAT_HEALTH_PERIOD
    FPGA_RESPONSE_PERIOD
    ACK_CMD_COUNT
    LAST_ACK_CMD_ID
    ERROR_CMD_COUNT
    LAST_ERROR_CMD_ID
    BOOT_COUNT
    DISK_USED_MEMORY
    DISK_FREE_MEMORY
    AVAILABLE_VIRTUAL_MEMORY
]
hk_sys_pkt_fixed_data_fields_len = hk_sys_pkt_fixed_data_fields.length
HK_SYS_FIXED_DATA_LEN = 27 #TODO: Add this to the packet def

while(true)
    #Get telemetry packet:
    packet = get_packet(tlm_id_PL_HK_SYS)

    #Parse CCSDS header:             
    _, _, _, pl_ccsds_apid, _, _, pl_ccsds_length =  parse_ccsds(packet) 
    apid_check_bool = pl_ccsds_apid == TLM_HK_SYS
    if !apid_check_bool
        err_msg_apid = "CCSDS APID Error! Received APID (= " + pl_ccsds_apid.to_s + ") not equal to PL_HK_SYS APID (= " + TLM_HK_SYS.to_s + ").\n"
        puts err_msg_apid
        File.open(file_path, 'a+') {|f| f.write(err_msg_apid)}
    end

    #Assemble HK Message
    message = ''
    for i in 0..(hk_sys_pkt_fixed_data_fields_len-1)
        message += ("[" + hk_sys_pkt_fixed_data_fields[i] + ': ' + packet.read(hk_sys_pkt_fixed_data_fields[i]).to_s + "] ")
    end
    message += "\n"
    puts (message)
    File.open(file_path, 'a+') {|f| f.write(message)}
    process_info_len = pl_ccsds_length - HK_SYS_FIXED_DATA_LEN - CRC_LEN + 1 #get data size
    
    if process_info_len > 0
        packing = 'C' + process_info_len.to_s + 'S>' #define packing for process info and crc
        process_info, crc_rx = parse_variable_data_and_crc(packet, packing) #parse process info variable length data and crc
        if process_info.length % 3 == 0
            for i in 0..(process_info.length - 3)
                proc_msg = ("Process Name: " + process_info[i].to_s + ", CPU Percent: " + process_info[i+1].to_s + ", Memory Percent: " + process_info[i+2].to_s + "\n")
            end
        else
            proc_msg = "Error process information is missing data (not a multiple of 3)\nRaw Process Info: ["
            for i in 0..(process_info.length - 1)
                proc_msg += (process_info[i].to_s + ", ")
            end
            proc_msg += "]\n"
        end
    else
        proc_msg = "No process information received. Payload services may not be running.\n"
        crc_rx = parse_empty_data_and_crc(packet) #parse process info variable length data and crc
    end
    puts proc_msg
    File.open(file_path, 'a+') {|f| f.write(proc_msg)}
    
    crc_check_bool, crc_check = check_pl_tlm_crc(packet, crc_rx) #check CRC
    if !crc_check_bool
        err_msg_crc = "CRC Error! Received CRC (= " + crc_rx.to_s + ") not equal to expected CRC (= " + crc_check.to_s + ").\n"
        puts err_msg_crc
        File.open(file_path, 'a+') {|f| f.write(err_msg_crc)}
    end

end