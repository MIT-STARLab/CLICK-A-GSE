#Test Script - Payload FPGA Map Housekeeping Telemetry
#Assumed Path: C:\CLICK-A-GSE\test\test_hk_ch_tlm.rb
load ('C:/CLICK-A-GSE/lib/click_cmd_tlm.rb')

#Subscribe to telemetry packets:
tlm_id_PL_HK_FPGA = subscribe_packet_data([['UUT', 'PL_HK_FPGA']], 500000) #set queue depth to 500000 (default is 1000)

#Save test results to text file:
current_timestamp, current_time_str = get_timestamp()
test_log_dir = (Cosmos::USERPATH + "/outputs/logs/xb1_click/")
file_name = "HK_FPGA_" + current_timestamp + ".csv"
file_path = test_log_dir + file_name
puts "Saving results to: " + file_path

header = ['TIME', 'APID_VALID', 'CRC_VALID', 'FPGA_COUNTER'] + ADDR_UNDER_128 + ADDR_200_300 + ADDR_EDFA + NAMES_DAC_BLOCK
csv = CSV.open(file_path, "a+")
CSV.open(file_path, 'a+') do |row|
    row << header
end

while(true)
    getHK_FPGA(file_path, tlm_id_PL_HK_FPGA)
end