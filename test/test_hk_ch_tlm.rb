#Test Script - Payload Commandhandler (CH) Housekeeping Telemetry
#Assumed Path: #Cosmos::USERPATH + \procedures\CLICK-A-GSE\test\test_hk_ch_tlm.rb
load (Cosmos::USERPATH + '/procedures/CLICK-A-GSE/lib/click_cmd_tlm.rb')

#Subscribe to telemetry packets:
tlm_id_PL_HK_CH = subscribe_packet_data([['UUT', 'PL_HK_CH']], 500000) #set queue depth to 500000 (default is 1000)

#Save test results to text file:
current_timestamp, current_time_str = get_timestamp()
test_log_dir = (Cosmos::USERPATH + "/outputs/logs/xb1_click/")
file_name = "HK_CH_" + current_timestamp + ".txt"
file_path = test_log_dir + file_name
File.open(file_path, 'a+') {|f| f.write("Housekeeping Telemetry - Commandhandler Health. Start Time: " + current_time_str + "\n")}

while(true)
    #getHK_CH(file_path, tlm_id_PL_HK_CH)
    #Get telemetry packet:
    packet = get_packet(tlm_id_PL_HK_CH)

    #Parse CCSDS header:             
    _, _, _, pl_ccsds_apid, _, _, pl_ccsds_length =  parse_ccsds(packet) 
    apid_check_bool = pl_ccsds_apid == TLM_HK_CH
    if !apid_check_bool
        err_msg_apid = "CCSDS APID Error! Received APID (= " + pl_ccsds_apid.to_s + ") not equal to PL_HK_CH APID (= " + TLM_HK_CH.to_s + ").\n"
        puts err_msg_apid
        File.open(file_path, 'a+') {|f| f.write(err_msg_apid)}
    end

    #Extract HK Message
    ch_health_len = pl_ccsds_length - CRC_LEN + 1 #get data size
    
    packing = 'a' + ch_health_len.to_s + 'S>' #define packing for process info and crc
    ch_health, crc_rx = parse_variable_data_and_crc(packet, packing) #parse process info variable length data and crc
    crc_check_bool, crc_check = check_pl_tlm_crc(packet, crc_rx) #check CRC
    if !crc_check_bool
        err_msg_crc = "CRC Error! Received CRC (= " + crc_rx.to_s + ") not equal to expected CRC (= " + crc_check.to_s + ").\n"
        puts err_msg_crc
        File.open(file_path, 'a+') {|f| f.write(err_msg_crc)}
    end

    puts ch_health
    File.open(file_path, 'a+') {|f| f.write(ch_health)}
end