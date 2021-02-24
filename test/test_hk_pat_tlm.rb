#Test Script - Payload PAT Housekeeping Telemetry
#Assumed Path: C:\CLICK-A-GSE\test\test_hk_pat_tlm.rb
load ('C:/CLICK-A-GSE/lib/click_cmd_tlm.rb')

#Subscribe to telemetry packets:
tlm_id_PL_HK_PAT = subscribe_packet_data([['UUT', 'PL_HK_PAT']], 500000) #set queue depth to 500000 (default is 1000)

#Save test results to text file:
current_timestamp, current_time_str = get_timestamp()
test_log_dir = (Cosmos::USERPATH + "/outputs/logs/xb1_click/")
file_name = "HK_PAT_" + current_timestamp + ".txt"
file_path = test_log_dir + file_name
File.open(file_path, 'a+') {|f| f.write("Housekeeping Telemetry - PAT Health. Start Time: " + current_time_str + "\n")}

while(true)
    getHK_PAT(file_path, tlm_id_PL_HK_PAT)
end