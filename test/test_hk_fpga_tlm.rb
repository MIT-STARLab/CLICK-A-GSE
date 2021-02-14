#Test Script - Payload FPGA Map Housekeeping Telemetry
#Assumed Path: #Cosmos::USERPATH + \procedures\CLICK-A-GSE\test\test_hk_ch_tlm.rb
load (Cosmos::USERPATH + '/procedures/CLICK-A-GSE/lib/click_cmd_tlm.rb')

#Subscribe to telemetry packets:
tlm_id_PL_HK_FPGA = subscribe_packet_data([['UUT', 'PL_HK_FPGA']], 500000) #set queue depth to 500000 (default is 1000)

#Save test results to text file:
current_timestamp, current_time_str = get_timestamp()
test_log_dir = (Cosmos::USERPATH + "/outputs/logs/xb1_click/")
file_name = "HK_FPGA_" + current_timestamp + ".csv"
file_path = test_log_dir + file_name

addr_UNDER_128 = (0..4).to_a + (32..38).to_a + [47,48,53,54,57] + (60..63).to_a + (96..109).to_a + (112..119).to_a
addr_EDFA = (602..611).to_a
names_DAC_BLOCK = ['DAC_1_A', 'DAC_1_B', 'DAC_1_C', 'DAC_1_D', 'DAC_2_A', 'DAC_2_B', 'DAC_2_C', 'DAC_2_D']
header = ['APID_VALID', 'CRC_VALID', 'FPGA_COUNTER'] + addr_UNDER_128 + addr_EDFA + names_DAC_BLOCK
csv = CSV.open(file_path, "a+")
CSV.open(file_path, 'a+') do |row|
    row << header
end
puts header.length

while(true)
    #Get telemetry packet:
    packet = get_packet(tlm_id_PL_HK_FPGA)
    packet_data = []
    #Parse CCSDS header:             
    _, _, _, pl_ccsds_apid, _, _, pl_ccsds_length =  parse_ccsds(packet) 
    apid_check_bool = pl_ccsds_apid == TLM_HK_FPGA_MAP
    if !apid_check_bool
        err_msg_apid = "CCSDS APID Error! Received APID (= " + pl_ccsds_apid.to_s + ") not equal to PL_HK_FPGA APID (= " + TLM_HK_FPGA_MAP.to_s + ").\n"
        puts err_msg_apid
        #File.open(file_path, 'a+') {|f| f.write(err_msg_apid)}
        packet_data += [0]
    else
        packet_data += [1]
    end

    #Extract CRC
    crc_rx = parse_empty_data_and_crc(packet) #parse crc
    crc_check_bool, crc_check = check_pl_tlm_crc(packet, crc_rx) #check CRC
    if !crc_check_bool
        err_msg_crc = "CRC Error! Received CRC (= " + crc_rx.to_s + ") not equal to expected CRC (= " + crc_check.to_s + ").\n"
        puts err_msg_crc
        #File.open(file_path, 'a+') {|f| f.write(err_msg_crc)}
        packet_data += [0]
    else
        packet_data += [1]
    end

    #Get FPGA Counter
    counter = packet.read('HK_FPGA_COUNTER')
    msg_counter = "------------------FPGA TLM COUNTER: " + counter.to_s + " ------------------"
    puts msg_counter
    #File.open(file_path, 'a+') {|f| f.write(msg_counter)}
    packet_data += [counter]

    #Parse FPGA Data - Select Registers Under 128: (0-4), (32-38), 47, 48, 53, 54, 57, (60-63), (96-109), (112-119)
    reg_UNDER_128 = packet.read('FPGA_REG_UNDER_128')
    msg_UNDER_128 = "Under 128 Block: "
    for i in 0..(reg_UNDER_128.length-1)
        msg_UNDER_128 += ("(Reg " + addr_UNDER_128[i].to_s + ": " + reg_UNDER_128[i].to_s + "), ")
        packet_data += [reg_UNDER_128[i]]
    end
    msg_UNDER_128 += "\n"
    puts msg_UNDER_128

    #File.open(file_path, 'a+') {|f| f.write(msg_UNDER_128)}

    #Parse FPGA Data - EDFA Registers (602-611)
    reg_602_EDFA_EN_PIN = packet.read('FPGA_REG_602_EDFA_EN_PIN')
    reg_603_EDFA_MODE = packet.read('FPGA_REG_603_EDFA_MODE')
    reg_604_EDFA_DIODE_ON = packet.read('FPGA_REG_604_EDFA_DIODE_ON')
    reg_605_EDFA_MYSTERY_TEMP = packet.read('FPGA_REG_605_EDFA_MYSTERY_TEMP')
    reg_606_EDFA_POWER_IN = packet.read('FPGA_REG_606_EDFA_POWER_IN')
    reg_607_EDFA_POWER_OUT = packet.read('FPGA_REG_607_EDFA_POWER_OUT')
    reg_608_EDFA_PRE_CURRENT = packet.read('FPGA_REG_608_EDFA_PRE_CURRENT')
    reg_609_EDFA_PRE_POWER = packet.read('FPGA_REG_609_EDFA_PRE_POWER')
    reg_610_EDFA_PUMP_CURRENT = packet.read('FPGA_REG_610_EDFA_PUMP_CURRENT')
    reg_611_EDFA_CASE_TEMP = packet.read('FPGA_REG_611_EDFA_CASE_TEMP')
    msg_EDFA = "EDFA Block: "
    msg_EDFA += ("(EDFA_EN_PIN: " + reg_602_EDFA_EN_PIN.to_s + "), ")
    msg_EDFA += ("(EDFA_MODE: " + reg_603_EDFA_MODE.to_s + "), ")
    msg_EDFA += ("(EDFA_DIODE_ON: " + reg_604_EDFA_DIODE_ON.to_s + "), ")
    msg_EDFA += ("(EDFA_MYSTERY_TEMP: " + reg_605_EDFA_MYSTERY_TEMP.to_s + "), ")
    msg_EDFA += ("(EDFA_POWER_IN: " + reg_606_EDFA_POWER_IN.to_s + "), ")
    msg_EDFA += ("(EDFA_POWER_OUT: " + reg_607_EDFA_POWER_OUT.to_s + "), ")
    msg_EDFA += ("(EDFA_PRE_CURRENT: " + reg_608_EDFA_PRE_CURRENT.to_s + "), ")
    msg_EDFA += ("(EDFA_PRE_POWER: " + reg_609_EDFA_PRE_POWER.to_s + "), ")
    msg_EDFA += ("(EDFA_PUMP_CURRENT: " + reg_610_EDFA_PUMP_CURRENT.to_s + "), ")
    msg_EDFA += ("(EDFA_CASE_TEMP: " + reg_611_EDFA_CASE_TEMP.to_s + ")\n")
    puts msg_EDFA
    #File.open(file_path, 'a+') {|f| f.write(msg_EDFA)}
    packet_data += [reg_602_EDFA_EN_PIN]
    packet_data += [reg_603_EDFA_MODE]
    packet_data += [reg_604_EDFA_DIODE_ON]
    packet_data += [reg_605_EDFA_MYSTERY_TEMP]
    packet_data += [reg_606_EDFA_POWER_IN]
    packet_data += [reg_607_EDFA_POWER_OUT]
    packet_data += [reg_608_EDFA_PRE_CURRENT]
    packet_data += [reg_609_EDFA_PRE_POWER]
    packet_data += [reg_610_EDFA_PUMP_CURRENT]
    packet_data += [reg_611_EDFA_CASE_TEMP]

    #Parse FPGA Data - DAC Registers (502-509)
    reg_DAC_BLOCK = packet.read('FPGA_REG_DAC_BLOCK')
    msg_DAC_BLOCK = "DAC Block: "
    for i in 0..(reg_DAC_BLOCK.length-1)
        msg_DAC_BLOCK += ("(" + names_DAC_BLOCK[i] + ": " + reg_DAC_BLOCK[i].to_s + "), ")
        packet_data += [reg_DAC_BLOCK[i]]
    end
    msg_DAC_BLOCK += "\n"
    puts msg_DAC_BLOCK
    #File.open(file_path, 'a+') {|f| f.write(msg_DAC_BLOCK)}

    #Write packet data to csv log
    CSV.open(file_path, 'a+') do |row|
        row << packet_data
    end
    puts packet_data.length
end