#Test Script - CLICK Command and Telemetry Manager
#Assumed Path: #C:\BCT\71sw0078_a_cosmos_click_edu\procedures\CLICK-A-GSE\test\click_cmd_tlm_manager.rb

require 'FileUtils' # Pretty sure COSMOS already requires this, so this is might be unnecessary
require 'digest/md5'
load 'C:/BCT/71sw0078_a_cosmos_click_edu/procedures/CLICK-A-GSE/lib/click_cmd_tlm.rb'

test_log_dir = "C:/BCT/71sw0078_a_cosmos_click_edu/outputs/logs/xb1_click/"

cmd_list = [
    CMD_PL_REBOOT,
    CMD_PL_ENABLE_TIME,
    CMD_PL_DISABLE_TIME,
    CMD_PL_EXEC_FILE,
    CMD_PL_LIST_FILE,
    CMD_PL_REQUEST_FILE,
    CMD_PL_UPLOAD_FILE,
    CMD_PL_ASSEMBLE_FILE,
    CMD_PL_VALIDATE_FILE,
    CMD_PL_MOVE_FILE,
    CMD_PL_DEL_FILE,
    CMD_PL_SET_PAT_MODE,
    CMD_PL_SINGLE_CAPTURE,
    CMD_PL_CALIB_LASER_TEST,
    CMD_PL_FSM_TEST,
    CMD_PL_RUN_CALIBRATION,
    CMD_PL_PAT_TEST,
    CMD_PL_END_PAT_PROCESS,
    CMD_PL_RESTART_PAT_PROCESS,
    CMD_PL_SET_FPGA,
    CMD_PL_GET_FPGA,
    CMD_PL_SET_HK,
    CMD_PL_ECHO,
    CMD_PL_NOOP,
    CMD_PL_SELF_TEST,
    CMD_PL_DWNLINK_MODE,
    CMD_PL_DEBUG_MODE,
]

cmd_names = %w[
    PL_REBOOT
    PL_ENABLE_TIME
    PL_DISABLE_TIME
    PL_EXEC_FILE
    PL_LIST_FILE
    PL_REQUEST_FILE
    PL_UPLOAD_FILE
    PL_ASSEMBLE_FILE
    PL_VALIDATE_FILE
    PL_MOVE_FILE
    PL_DEL_FILE
    PL_SET_PAT_MODE
    PL_SINGLE_CAPTURE
    PL_CALIB_LASER_TEST
    PL_FSM_TEST
    PL_RUN_CALIBRATION
    PL_PAT_TEST
    PL_END_PAT_PROCESS
    PL_RESTART_PAT_PROCESS
    PL_SET_FPGA
    PL_GET_FPGA
    PL_SET_HK
    PL_ECHO
    PL_NOOP
    PL_SELF_TEST
    PL_DWNLINK_MODE
    PL_DEBUG_MODE
]

self_test_list = [
    GENERAL_SELF_TEST,
    LASER_SELF_TEST,
    PAT_SELF_TEST,
]

self_test_names = %w[
    PL_GENERAL_SELF_TEST
    PL_LASER_SELF_TEST
    PL_PAT_SELF_TEST
]

pat_mode_list = [
    PAT_MODE_DEFAULT,
    PAT_MODE_OPEN_LOOP,
    PAT_MODE_STATIC_POINTING,
    PAT_MODE_DEFAULT_BUS_FEEDBACK,
    PAT_MODE_OPEN_LOOP_BUS_FEEDBACK,
    PAT_MODE_BEACON_ALIGN,
]

pat_mode_names = %w[
    DEFAULT
    OPEN_LOOP
    STATIC_POINTING
    DEFAULT_BUS_FEEDBACK
    OPEN_LOOP_BUS_FEEDBACK
    BEACON_ALIGN
]

def get_timestamp()
    current_time = Time.now #time of test start
    current_time_str = current_time.to_s #human readable time
    current_timestamp = current_time.to_f.floor.to_s #timestamp in seconds
    return current_timestamp, current_time_str
end

#Subscribe to telemetry packets:
tlm_id_PL_ECHO = subscribe_packet_data([['UUT', 'PL_ECHO']], 10000) #set queue depth to 10000 (default is 1000)
tlm_id_PL_LIST_FILE = subscribe_packet_data([['UUT', 'PL_LIST_FILE']], 10000) #set queue depth to 10000 (default is 1000)
tlm_id_PL_PAT_SELF_TEST = subscribe_packet_data([['UUT', 'PL_PAT_SELF_TEST']], 10000) #set queue depth to 10000 (default is 1000)
tlm_id_PL_GET_FPGA = subscribe_packet_data([['UUT', 'PL_GET_FPGA']], 10000) #set queue depth to 10000 (default is 1000)

while true
    user_cmd = combo_box("Select a command (or EXIT): ", 
    cmd_names[0], cmd_names[1], cmd_names[2], cmd_names[3], cmd_names[4], cmd_names[5], 
    cmd_names[6], cmd_names[7], cmd_names[8], cmd_names[9], cmd_names[10], cmd_names[11],
    cmd_names[12], cmd_names[13], cmd_names[14], cmd_names[15], cmd_names[16], cmd_names[17], 
    cmd_names[18], cmd_names[19], cmd_names[20], cmd_names[21], cmd_names[22], cmd_names[23], 
    cmd_names[24], cmd_names[25], cmd_names[26],
    'TEST_MULTIPLE_ECHO', 'EXIT')
    if cmd_names.include? user_cmd
        if user_cmd == 'PL_REBOOT'
            #DC Send via UUT Payload Write (i.e. send CMD_ID only with empty data field)
            click_cmd(CMD_PL_REBOOT)

        elsif user_cmd == 'PL_ENABLE_TIME'
            #DC Send via UUT Payload Write (i.e. send CMD_ID only with empty data field)
            click_cmd(CMD_PL_ENABLE_TIME)

        elsif user_cmd == 'PL_DISABLE_TIME'
            #DC Send via UUT Payload Write (i.e. send CMD_ID only with empty data field)
            click_cmd(CMD_PL_DISABLE_TIME)

        elsif user_cmd == 'PL_EXEC_FILE'
            #define file path:
            file_path = ask_string("For PL_EXEC_FILE, input the payload file path (e.g. 'python /root/test/test_file_exc.py'). Input EXIT to escape.", 'EXIT')

            if file_path != 'EXIT'
                #define data bytes
                data = []
                data[0] = 0x00 #output script prints to file? Enable = 0xFF, Disable = 0x00
                data[1] = 0 #file output number (if outputting script prints to file)
                data[2] = file_path.length
                data[3] = file_path 
                packing = "C2S>" + "a" + file_path.length.to_s

                #SM Send via UUT PAYLOAD_WRITE
                click_cmd(CMD_PL_EXEC_FILE, data, packing) 

                #TODO: Get file output telemetry...
            end

        elsif user_cmd == 'PL_LIST_FILE'
            #define directory path:
            directory_path = ask_string("For PL_LIST_FILE, input the directory path (e.g. '/root/test'). Input EXIT to escape.", 'EXIT')

            if directory_path != 'EXIT'
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
                
                #Output message:
                message = ""
                if !apid_check_bool
                    message += "CCSDS APID Error! Received APID (= " + pl_ccsds_apid.to_s + ") not equal to PL_LIST_FILE APID (= " + TLM_ECHO.to_s + ").\n"
                end
                if !crc_check_bool
                    message += "CRC Error! Received CRC (= " + crc_rx.to_s + ") not equal to expected CRC (= " + crc_check.to_s + ").\n"
                end
                message += list_file_data
                prompt(message)
            end

        elsif user_cmd == 'PL_REQUEST_FILE'
            prompt("PL_REQUEST_FILE not yet implemented.")
            #define file path:
            # file_path = ask_string("For PL_REQUEST_FILE, input the payload file path (e.g. /root/log/pat/img_file_name.png). Input EXIT to escape.", 'EXIT')
            # #can get image name via list file command or via housekeeping tlm stream or PAT .txt telemetry file
            
            # if file_path != 'EXIT'
            #     ###TODO: request file function
            # end

        elsif user_cmd == 'PL_UPLOAD_FILE'
            ###TODO... maybe just call test_upload_file.rb
            prompt("PL_UPLOAD_FILE not yet implemented.")

        elsif user_cmd == 'PL_ASSEMBLE_FILE'
            prompt("PL_ASSEMBLE_FILE not yet implemented.")

            # file_name = ask_string("For PL_ASSEMBLE_FILE, input the payload file path (e.g. /root/file_staging/1/pat). Input EXIT to escape.", 'EXIT')            
            # if file_name != 'EXIT'
            #     transfer_id = 1 #TODO
            #     assemble_file(transfer_id, file_path)
            # end

        elsif user_cmd == 'PL_VALIDATE_FILE'
            prompt("PL_VALIDATE_FILE not yet implemented.")

            # file_name = ask_string("For PL_VALIDATE_FILE, input the payload file path (e.g. pat). Input EXIT to escape.", 'EXIT')

            # if file_name != 'EXIT'
            #     validate_file(md5, payload_file_path_staging)
            # end

        elsif user_cmd == 'PL_MOVE_FILE'
            source_file_path = ask_string("For PL_MOVE_FILE, input the file source path (e.g. '/root/test/test_tlm.txt'). Input EXIT to escape.", 'EXIT')
            if source_file_path != 'EXIT'
                destination_file_path = ask_string("For PL_MOVE_FILE, input the file destination path (e.g. '/root/log'). Input EXIT to escape.", 'EXIT')
                if destination_file_path != 'EXIT'
                    move_file(payload_file_path_staging, destination_file_path)
                    #TODO: encapsulate list file as a function after it's tested and use it here to display the destination (and source) directory
                end
            end

        elsif user_cmd == 'PL_DEL_FILE'
            file_path = ask_string("For PL_DEL_FILE, input the file path (e.g. '/root/test/test_tlm.txt'). Input EXIT to escape.", 'EXIT') #TBR path or name?
            if file_path != 'EXIT'
                recursive_cmd = message_box("For PL_DEL_FILE, recursive delete? ", 'YES', 'NO', 'EXIT')
                if recursive_cmd == 'YES'
                    recursive = 0xFF
                    execute = true
                elsif recursive_cmd == 'NO'
                    recursive = 0x00
                    execute = true
                elsif recursive_cmd == 'EXIT'
                    execute = false
                end
                
                if execute
                    delete_file(recursive, file_path)
                    #TODO: encapsulate list file as a function after it's tested and use it here to display the directory                 
                end
            end

        elsif user_cmd == 'PL_SET_PAT_MODE'
            user_pat_mode = combo_box("Select PAT mode (or EXIT).", 
            pat_mode_names[0], pat_mode_names[1], pat_mode_names[2], pat_mode_names[3], pat_mode_names[4], 'EXIT')
            if pat_mode_names.include? user_pat_mode
                pat_mode = pat_mode_list[pat_mode_names.find_index(user_pat_mode)]                

                #define data bytes
                data = []
                data[0] = pat_mode
                packing = "C"

                #SM Send via UUT PAYLOAD_WRITE
                click_cmd(CMD_PL_SET_PAT_MODE, data, packing)
            end

        elsif user_cmd == 'PL_SINGLE_CAPTURE'
            user_exp = ask("For PL_SINGLE_CAPTURE, input exposure time (us) (between 10 and 10000000). Input EXIT to escape.", 'EXIT') 
            if user_exp != 'EXIT'
                if user_exp >= 10 and user_exp <= 10000000
                    #define data bytes
                    data = []
                    data[0] = user_exp
                    packing = "L>"

                    #SM Send via UUT Payload Write
                    click_cmd(CMD_PL_SINGLE_CAPTURE, data, packing)

                    #TODO: Get image telemetry

                else
                    prompt("Exposure time out of bounds (10 to 10000000).")
                end
            end

        elsif user_cmd == 'PL_CALIB_LASER_TEST'
            user_exp = ask("For PL_CALIB_LASER_TEST, input exposure time (us) (between 10 and 10000000). Input EXIT to escape.", 'EXIT')
            if user_exp != 'EXIT'
                if user_exp >= 10 and user_exp <= 10000000
                    #define data bytes
                    data = []
                    data[0] = user_exp
                    packing = "L>"

                    #SM Send via UUT Payload Write
                    click_cmd(CMD_PL_CALIB_LASER_TEST, data, packing)

                    #TODO: Get image telemetry

                else
                    prompt("Exposure time out of bounds (10 to 10000000).")
                end
            end

        elsif user_cmd == 'PL_FSM_TEST'
            user_exp = ask("For PL_FSM_TEST, input exposure time (us) (between 10 and 10000000). Input EXIT to escape.", 'EXIT')
            if user_exp != 'EXIT'
                if user_exp >= 10 and user_exp <= 10000000
                    #define data bytes
                    data = []
                    data[0] = user_exp
                    packing = "L>"

                    #SM Send via UUT Payload Write
                    click_cmd(CMD_PL_FSM_TEST, data, packing)

                    #TODO: Get image telemetry
                else
                    prompt("Exposure time out of bounds (10 to 10000000).")
                end
            end

        elsif user_cmd == 'PL_RUN_CALIBRATION'
            #DC Send via UUT Payload Write (i.e. send CMD_ID only with empty data field)
            click_cmd(CMD_PL_RUN_CALIBRATION)

        elsif user_cmd == 'PL_PAT_TEST'
            prompt("Ensure PAT Health Telemetry stream is running before proceeding.\n(i.e. Run test_hk_pat_tlm.rb in a separate window.)")

            #Run Calibration
            click_cmd(CMD_PL_RUN_CALIBRATION)

            #Get confirmation of calibration (User Prompt) #TODO: automate this
            prompt("Observe PAT Health Telemetry and wait for calibration to complete before proceeding.")

            #Turn on Beacon (User Prompt)
            prompt("Turn ON Beacon Laser via GSE before proceeding.")

            #Start Main Pat Loop via DC Send via UUT Payload Write (i.e. send CMD_ID only with empty data field)
            click_cmd(CMD_PL_PAT_TEST)

            #Turn on Dithering (User Prompt)
            prompt("Start Beacon Dithering via GSE GUI.\nWait for dithering script to complete.\nPress Continue to END PAT process.")

            #End PAT process
            click_cmd(CMD_PL_END_PAT_PROCESS)

            #Get telemetry from payload (User Prompt ) #TODO: automate this
            prompt("Pull PAT telemetry files from payload. \nPress Continue to restart PAT process.")

            #Restart PAT process?
            click_cmd(CMD_PL_RESTART_PAT_PROCESS)

        elsif user_cmd == 'PL_END_PAT_PROCESS'
            #DC Send via UUT Payload Write (i.e. send CMD_ID only with empty data field)
            click_cmd(CMD_PL_END_PAT_PROCESS)

        elsif user_cmd == 'PL_RESTART_PAT_PROCESS'
            #DC Send via UUT Payload Write (i.e. send CMD_ID only with empty data field)
            click_cmd(CMD_PL_RESTART_PAT_PROCESS)

        elsif user_cmd == 'PL_SET_FPGA'
            #define request number, start address, and data to write
            user_request_number = ask("For PL_SET_FPGA, input request number (between 0 and 255). Input EXIT to escape.", 'EXIT')
            if user_request_number != 'EXIT'
                if user_request_number >= 0 and user_request_number <= 255
                    user_start_address = ask("For PL_SET_FPGA, input start register address.")
                    user_num_registers = ask("For PL_SET_FPGA, input number of registers to write.")
                    user_write_data = []
                    for i in 0..(user_num_registers-1)
                        user_write_data_i = ask("For PL_SET_FPGA, input data to write to register #{start_address + i}.")
                        user_write_data += [user_write_data_i] 
                    end               
                    
                    #define data bytes
                    data = []
                    data[0] = user_request_number
                    data[1] = user_start_address
                    data[2] = user_write_data.length
                    data += user_write_data
                    packing = "CL>C" + "L>" + user_write_data.length.to_s
        
                    #SM Send via UUT PAYLOAD_WRITE
                    click_cmd(CMD_PL_SET_FPGA, data, packing)
                else
                    prompt("Request number out of bounds (0 to 255)")
                end
            end

        elsif user_cmd == 'PL_GET_FPGA'
            #define request number, start address, and data to write
            user_request_number = ask("For PL_GET_FPGA, input request number (between 0 and 255). Input EXIT to escape.", 'EXIT')
            if user_request_number != 'EXIT'
                if user_request_number >= 0 and user_request_number <= 255
                    user_start_address = ask("For PL_GET_FPGA, input start register address.")
                    user_num_registers = ask("For PL_GET_FPGA, input number of registers to read.")         

                    #define data bytes
                    data = []
                    data[0] = user_request_number
                    data[1] = user_start_address
                    data[2] = user_num_registers
                    packing = "CL>C"

                    #SM Send via UUT PAYLOAD_WRITE
                    click_cmd(CMD_PL_GET_FPGA, data, packing)

                    #Get telemetry packet:
                    packet = get_packet(tlm_id_PL_GET_FPGA)   

                    #Parse CCSDS header:             
                    _, _, _, pl_ccsds_apid, _, _, pl_ccsds_length =  parse_ccsds(packet) 
                    apid_check_bool = pl_ccsds_apid == TLM_GET_FPGA

                    request_num_rx = packet.read('REQUEST_NUM')
                    start_addr_rx = packet.read('START_ADDRESS')
                    num_registers_rx = packet.read('SIZE')

                    request_num_check = request_num_rx == user_request_number
                    start_addr_check = start_addr_rx == user_start_address
                    num_registers_check = num_registers_rx == user_num_registers
                    
                    #Define variable length data packing:
                    packing = "L>" + num_registers_rx.to_s + "S>" #define data packing for telemetry packet

                    #Read the data bytes and check CRC:
                    read_data, crc_rx = parse_variable_data_and_crc(packet, packing) #parse variable length data and crc
                    crc_check_bool, crc_check = check_pl_tlm_crc(packet, crc_rx) #check CRC
                    
                    summary_message = "PL_GET_FPGA: \n"
                    if !apid_check_bool
                        summary_message += ("CCSDS APID Error! Received APID (= " + pl_ccsds_apid.to_s + ") not equal to PL_GET_FPGA APID (= " + TLM_GET_FPGA.to_s + ").\n")
                    end
                    if !crc_check_bool
                        summary_message += ("CRC Error! Received CRC (= " + crc_rx.to_s + ") not equal to expected CRC (= " + crc_check.to_s + ").\n")
                    end
                    if !request_num_check
                        summary_message += ("Request Number Error! Received request number (= " + request_num_rx.to_s + ") not equal to transmitted request number (= " + user_request_number.to_s + ").\n")
                    end
                    if !request_num_check
                        summary_message += ("Request Number Error! Received start address (= " + start_addr_check.to_s + ") not equal to transmitted start address (= " + user_start_address.to_s + ").\n")
                    end
                    if !request_num_check
                        summary_message += ("Request Number Error! Received number of registers (= " + num_registers_rx.to_s + ") not equal to requested number of registers (= " + user_num_registers.to_s + ").\n")
                    end
                    summary_message += "Read Data: \n"
                    for i in 0..(num_registers_rx-1)
                        register = start_addr_rx + i
                        summary_message += ("Register: " + register.to_s + ", Value: " + read_data[i].to_s + "\n")
                    end
                    prompt(summary_message)
                else
                    prompt("Request number out of bounds (0 to 255)")
                end
            end

        elsif user_cmd == 'PL_SET_HK'
            prompt("PL_SET_HK not yet implemented.")

        elsif user_cmd == 'PL_ECHO'
            user_echo_data = ask_string("For PL_ECHO, input string to echo. Input EXIT to escape.", 'EXIT')
            if user_echo_data != 'EXIT'
                #define data bytes
                data = []
                data[0] = user_echo_data
                packing = "a" + user_echo_data.length.to_s

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
            end

        elsif user_cmd == 'PL_NOOP'
            #DC Send via UUT Payload Write (i.e. send CMD_ID only with empty data field)
            click_cmd(CMD_PL_NOOP)

        elsif user_cmd == 'PL_SELF_TEST'
            user_test_name = combo_box("Select test (or EXIT): ", self_test_names[0], self_test_names[1], self_test_names[2], 'EXIT')
            if self_test_names.include? user_test_name
                test_id = self_test_list[self_test_names.find_index(user_test_name)]                

                #define data bytes
                data = []
                data[0] = test_id
                packing = "C"

                #SM Send via UUT PAYLOAD_WRITE
                click_cmd(CMD_PL_SELF_TEST, data, packing)

                if test_id == PAT_SELF_TEST
                    #Get telemetry packet:
                    packet = get_packet(tlm_id_PL_PAT_SELF_TEST)   
                    current_timestamp, current_time_str = get_timestamp()

                    #Parse CCSDS header:             
                    _, _, _, pl_ccsds_apid, _, _, pl_ccsds_length =  parse_ccsds(packet) 
                    apid_check_bool = pl_ccsds_apid == TLM_PAT_SELF_TEST

                    #Get Test Flags
                    camera_test_flag = packet.read('CAMERA_TEST_FLAG')
                    fpga_ipc_test_flag = packet.read('FPGA_IPC_TEST_FLAG')
                    laser_test_flag = packet.read('LASER_TEST_FLAG')
                    fsm_test_flag = packet.read('FSM_TEST_FLAG')
                    calibration_test_flag = packet.read('CALIBRATION_TEST_FLAG')
                    test_results = [camera_test_flag, fpga_ipc_test_flag, laser_test_flag, fsm_test_flag, calibration_test_flag]
                    test_names = ["Camera", "FPGA IPC", "Calibration Laser", "FSM", "Calibration"]
                    summary_message = ""
                    for i in 0..(test_results.length-1)
                        if test_results[i] == PAT_PASS_SELF_TEST
                            summary_message += (test_names[i] + " Test: PASSED\n")
                            self_test_pass_bool = true
                        elsif test_results[i] == PAT_NULL_SELF_TEST
                            summary_message += (test_names[i] + " Test: N/A\n")
                            self_test_pass_bool = false
                        elsif test_results[i] == PAT_FAIL_SELF_TEST
                            summary_message += (test_names[i] + " Test: FAILED\n")
                            self_test_pass_bool = false
                        else
                            summary_message += (test_names[i] + " Test: Unrecognized Result = " + camera_test_flag.to_s + "\n")
                            self_test_pass_bool = false
                    end
                    
                    #Get test error message if available
                    if !self_test_pass_bool
                        error_data_length = pl_ccsds_length - 5 - CRC_LEN + 1 #get data size
                        packing = "a" + error_data_length.to_s + "S>" #define data packing for telemetry packet
                        error_data, crc_rx = parse_variable_data_and_crc(packet, packing) #parse variable length data and crc
                    else
                        crc_rx = parse_empty_data_and_crc(packet) #parse crc
                    end
                    #Check CRC:
                    crc_check_bool, crc_check = check_pl_tlm_crc(packet, crc_rx) #check CRC                    
                    
                    #Determine if self test was successful and if not, generate error message:
                    success_bool = apid_check_bool and crc_check_bool and self_test_pass_bool
                    if success_bool
                        summary_message = "PAT Self Test: PASSED.\n" + summary_message
                    else
                        summary_message = "PAT Self Test: FAILED.\n" + summary_message
                        if !apid_check_bool
                            summary_message += "CCSDS APID Error! Received APID (= " + pl_ccsds_apid.to_s + ") not equal to PL_PAT_SELF_TEST APID (= " + TLM_PAT_SELF_TEST.to_s + ").\n"
                        end
                        if !crc_check_bool
                            summary_message += "CRC Error! Received CRC (= " + crc_rx.to_s + ") not equal to expected CRC (= " + crc_check.to_s + ").\n"
                        end
                        if !self_test_pass_bool
                            summary_message += (error_data + "\n")
                        end
                    end

                    #Save test results to text file:
                    file_name = "PAT_SELF_TEST_RESULTS_" + current_timestamp + ".txt"
                    file_path = test_log_dir + file_name
                    File.open(file_path, 'a+') {|f| f.write("PAT_SELF_TEST. Start Time: " + current_time_str + "\n")}
                    File.open(file_path, 'a+') {|f| f.write(summary_message)}
                    prompt(summary_message + "Results saved to: " + file_path)
                end
            end

        elsif user_cmd == 'PL_DWNLINK_MODE'
            #DC Send via UUT Payload Write (i.e. send CMD_ID only with empty data field)
            click_cmd(CMD_PL_DWNLINK_MODE)

        elsif user_cmd == 'PL_DEBUG_MODE'
            #DC Send via UUT Payload Write (i.e. send CMD_ID only with empty data field)
            click_cmd(CMD_PL_DEBUG_MODE)

        end

    elsif user_cmd == 'TEST_MULTIPLE_ECHO'
        num_echo_tests = ask("For TEST_MULTIPLE_ECHO, enter number of echo tests to perform: ")
        current_timestamp, current_time_str = get_timestamp()
        message_list = []
        num_errors = 0
        for i in 0..(num_echo_tests-1)
            echo_data_tx = "TEST " + i.to_s 
            success_bool, error_message = echo_test(echo_data_tx, tlm_id_PL_ECHO)
            if success_bool
                message_list += ["[" + Time.now.to_s + " " + echo_data_tx + "] Echo Success!\n"]
            else
                num_errors += 1
                message_list += ["[" + Time.now.to_s + " " + echo_data_tx + "] " + error_message + "\n"]
            end
        end

        #Save test results to text file:
        file_name = "TEST_MULTIPLE_ECHO_" + current_timestamp + ".txt"
        file_path = test_log_dir + file_name
        File.open(file_path, 'a+') {|f| f.write("TEST_MULTIPLE_ECHO. Start Time: " + current_time_str + "\n")}
        if num_errors == 0
            summary_message = "TEST_MULTIPLE_ECHO ran successfully with " + num_echo_tests.to_s + " packets with no errors.\n"
        else
            summary_message = "TEST_MULTIPLE_ECHO with " + num_echo_tests.to_s + " packets encountered " + num_errors.to_s + " echo failures.\n"
        end
        File.open(file_path, 'a+') {|f| f.write(summary_message)}
        for i in 0..(message_list.length-1)
            File.open(file_path, 'a+') {|f| f.write(message_list[i])}
        end
        prompt(summary_message + "Results saved to: " + file_path)

    else #EXIT
        break 
    end
end

