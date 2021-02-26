#Logging Script - Save Bus Power Telemetry to Text File
#To Exit: press Stop button (preferably during wait period between saves - line 90)
#Assumed Path: C:\CLICK-A-GSE\test\log_bus_power.rb
require "csv"
load ('C:/CLICK-A-GSE/lib/click_cmd_tlm.rb')

tlm_id_POWER = subscribe_packet_data([['UUT', 'POWER']], 500000) #set queue depth to 100000 (default is 1000)

#save_period_sec = 1
current_timestamp, current_time_str = get_timestamp()

#Save test results to text file:
test_log_dir = (Cosmos::USERPATH + "/outputs/logs/xb1_click/")
file_name = "LOG_POWER_" + current_timestamp + ".csv"
file_path = test_log_dir + file_name
puts "Saving results to: " + file_path

power_pkt_data_fields = %w[
    CCSDS_TAI_SECS
    CCSDS_REALTIME
    HEATER_CTRL_CONFIG1
    HEATER_STATUS1
    POWER_STATUS
    IO1_SDR_S_TT_C
    IO2_BUS_HEATER
    IO3_GPS_3V3
    IO4_PAYLOAD
    IO5_CROSSLINK_RADIO
    IO9_PAYLOAD_HEATER
    IO10_RELEASE_MECH
    IO17_BAT_CHRG_EN
    IO18_OUT_MPPT_EN
    IO19_BATTERY_HTR_1_EN
    IO22_V3_EN
    IO23_V4_EN
    IO26_CROSSLINK
    IO27_PAYLOAD_ENABLE
    IO28_TIME_TONE
    I2C_ERR_COUNT
    I2C_RETRY_COUNT
    CMD_ACCEPT_CNT
    CMD_REJECT_CNT
    FAULT_STAT
    BATTERY_PRESENT
    INPUT_FAULT
    OVER_VOLTAGE3
    OVER_VOLTAGE2
    OVER_VOLTAGE1
    OVER_CURRENT3
    OVER_CURRENT2
    OVER_CURRENT1
    STATUS
    PWM_MODE
    MPPT_STATUS
    CONVERTER_MODE
    SEP_MON
    RUN_COUNT
    SETPOINT_BAT_1_CUR
    SETPOINTS2
    SETPOINTS3
    SETPOINT_BAT_VOLT
    SETPOINT_CONV_CUR
    FPGA_SERIAL_NUMBER
    FPGA_VERSION
    OFFSETS
]
power_pkt_data_fields_len = power_pkt_data_fields.length

csv = CSV.open(file_path, "a+")
CSV.open(file_path, 'a+') do |row|
    row << (['TIME'] + power_pkt_data_fields)
end

while true
    #Get telemetry packet:
    packet = get_packet(tlm_id_POWER)

    #Get packet data
    packet_data = [Time.now.to_s]
    for i in 0..(power_pkt_data_fields_len-1)
        packet_data += [packet.read(power_pkt_data_fields[i])]
    end

    #Write packet data to csv log
    CSV.open(file_path, 'a+') do |row|
        row << packet_data
    end
    
    #sleep(save_period_sec)
end