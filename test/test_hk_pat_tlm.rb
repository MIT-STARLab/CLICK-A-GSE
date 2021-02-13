#Test Script - Payload PAT Housekeeping Telemetry
#Assumed Path: #Cosmos::USERPATH + \procedures\CLICK-A-GSE\test\test_hk_pat_tlm.rb
load (Cosmos::USERPATH + '/procedures/CLICK-A-GSE/lib/click_cmd_tlm.rb')

#Subscribe to telemetry packets:
tlm_id_PL_HK_PAT = subscribe_packet_data([['UUT', 'PL_HK_PAT']], 10000) #set queue depth to 10000 (default is 1000)

while(true)
    #Get telemetry packet:
    packet = get_packet(tlm_id_PL_HK_PAT)

    #Parse CCSDS header:             
    _, _, _, pl_ccsds_apid, _, _, pl_ccsds_length =  parse_ccsds(packet) 
    apid_check_bool = pl_ccsds_apid == TLM_HK_PAT
    if !apid_check_bool
        puts "CCSDS APID Error! Received APID (= " + pl_ccsds_apid.to_s + ") not equal to PL_HK_PAT APID (= " + TLM_HK_PAT.to_s + "). "
    end

    #Extract HK Message
    pat_health_len = pl_ccsds_length - CRC_LEN + 1 #get data size
    
    packing = 'a' + pat_health_len.to_s + 'S>' #define packing for process info and crc
    pat_health, crc_rx = parse_variable_data_and_crc(packet, packing) #parse process info variable length data and crc
    crc_check_bool, crc_check = check_pl_tlm_crc(packet, crc_rx) #check CRC
    if !crc_check_bool
        puts "CRC Error! Received CRC (= " + crc_rx.to_s + ") not equal to expected CRC (= " + crc_check.to_s + "). "
    end

    puts pat_health
end