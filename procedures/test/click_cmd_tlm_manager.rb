#Test Script - CLICK Command and Telemetry Manager
#Assumed Path: #C:\BCT\71sw0078_a_cosmos_click_edu\procedures\test\click_cmd_tlm_manager.rb

require 'FileUtils' # Pretty sure COSMOS already requires this, so this is might be unnecessary
require 'digest/md5'
load 'C:/BCT/71sw0078_a_cosmos_click_edu/procedures/lib/pl_cmd_tlm_apids.rb'
load 'C:/BCT/71sw0078_a_cosmos_click_edu/procedures/lib/click_cmd.rb'

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
    TEST_PAT_HW,
]

self_test_names = %w[
    PAT_HW
]

pat_mode_list = [
    PAT_MODE_DEFAULT,
    PAT_MODE_OPEN_LOOP,
    PAT_MODE_STATIC_POINTING,
    PAT_MODE_BUS_FEEDBACK,
]

pat_mode_names = %w[
    DEFAULT
    OPEN_LOOP
    STATIC_POINTING
    BUS_FEEDBACK
]

while true
    user_cmd = combo_box("Select a command (or EXIT): ", 
    cmd_names[0], cmd_names[1], cmd_names[2], cmd_names[3], cmd_names[4], cmd_names[5], 
    cmd_names[6], cmd_names[7], cmd_names[8], cmd_names[9], cmd_names[10], cmd_names[11],
    cmd_names[12], cmd_names[13], cmd_names[14], cmd_names[15], cmd_names[16], cmd_names[17], 
    cmd_names[18], cmd_names[19], cmd_names[20], cmd_names[21], cmd_names[22], cmd_names[23], 
    'EXIT')
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
            file_path = ask("For PL_EXEC_FILE, input the payload file path (e.g. /root/bin/pat). Input EXIT to escape.", 'EXIT')

            if file_path != 'EXIT'
                #define data bytes
                data = []
                data[0] = 0x00 #output script prints to file? Enable = 0xFF, Disable = 0x00
                data[1] = 0 #file output number (if outputting script prints to file)
                data[2] = file_path.length
                data[3] = file_path 
                packing = "C3" + "a" + file_path.length.to_s

                #SM Send via UUT PAYLOAD_WRITE
                click_cmd(CMD_PL_EXEC_FILE, data, packing) 

                #TODO: Get file output telemetry...
            end

        elsif user_cmd == 'PL_LIST_FILE'
            #define directory path:
            directory_path = ask("For PL_LIST_FILE, input the directory path (e.g. /root/bin). Input EXIT to escape.", 'EXIT')

            if directory_path != 'EXIT'
                #define data bytes
                data = []
                data[0] = directory_path.length
                data[1] = directory_path 
                packing = "C" + "a" + directory_path.length.to_s

                #SM Send via UUT PAYLOAD_WRITE
                click_cmd(CMD_PL_LIST_FILE, data, packing)

                #TODO: Get file list telemetry...
            end

        elsif user_cmd == 'PL_REQUEST_FILE'
            #define file path:
            file_path = ask("For PL_REQUEST_FILE, input the payload file path (e.g. /root/log/pat/img_file_name.png). Input EXIT to escape.", 'EXIT')
            #can get image name via list file command or via housekeeping tlm stream or PAT .txt telemetry file
            
            if file_path != 'EXIT'
                #define data bytes
                data = []
                data[0] = file_path.length
                data[1] = file_path 
                packing = "C" + "a" + file_path.length.to_s

                #SM Send via UUT PAYLOAD_WRITE
                click_cmd(CMD_PL_REQUEST_FILE, data, packing)

                #TODO: Get file telemetry...
            end

        elsif user_cmd == 'PL_UPLOAD_FILE'
            ###TODO... maybe just call test_upload_file.rb
            prompt("PL_UPLOAD_FILE not yet implemented.")

        elsif user_cmd == 'PL_ASSEMBLE_FILE'
            file_name = ask("For PL_ASSEMBLE_FILE, input the payload file name (e.g. pat). Input EXIT to escape.", 'EXIT')
            #TBR (should it just be the file name or the whole path?)

            if file_name != 'EXIT'
                transfer_id = 1 #TBR

                #define data bytes
                data = []
                data[0] = transfer_id
                data[1] = file_name.length
                data[2] = file_name 
                packing = "S>2" + "a" + file_name.length.to_s
                
                #SM Send via UUT PAYLOAD_WRITE
                click_cmd(CMD_PL_ASSEMBLE_FILE, data, packing)
                
                #TODO: Get telemetry...
            end

        elsif user_cmd == 'PL_VALIDATE_FILE'
            file_name = ask("For PL_VALIDATE_FILE, input the payload file name (e.g. pat). Input EXIT to escape.", 'EXIT')
            #TBR (should it just be the file name or the whole path?)

            if file_name != 'EXIT'
                md5 = Digest::MD5.file file_name #what's the packing type? uint8 or string...
                
                #define data bytes
                data = []
                data[0] = md5
                data[1] = file_name.length
                data[2] = file_name 
                packing = "C" + md5.length.to_s + "S>" + "a" + file_name.length.to_s
                
                #SM Send via UUT PAYLOAD_WRITE
                click_cmd(CMD_PL_VALIDATE_FILE, data, packing)
                
                #TODO: Get telemetry...
            end

        elsif user_cmd == 'PL_MOVE_FILE'
            source_file_name = ask("For PL_MOVE_FILE, input the file source path (e.g. '/root/bin/pat'). Input EXIT to escape.", 'EXIT')
            if source_file_name != 'EXIT'
                destination_file_name = ask("For PL_MOVE_FILE, input the file destination path (e.g. '/root/pat'). Input EXIT to escape.", 'EXIT')
                if destination_file_name != 'EXIT'
                    #define data bytes
                    data = []
                    data[0] = source_file_name.length
                    data[1] = destination_file_name.length
                    data[2] = source_file_name 
                    data[3] = destination_file_name
                    packing = "S>2" + "a" + source_file_name.length.to_s + "a" + source_file_name.length.to_s
                    
                    #SM Send via UUT PAYLOAD_WRITE
                    click_cmd(CMD_PL_MOVE_FILE, data, packing)
                    
                    #TODO: Get telemetry...
                end
            end

        elsif user_cmd == 'PL_DEL_FILE'
            file_name = ask("For PL_DEL_FILE, input the file path (e.g. '/root/bin/pat'). Input EXIT to escape.", 'EXIT') #TBR path or name?
            if file_name != 'EXIT'
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
                    #define data bytes
                    data = []
                    data[0] = recursive
                    data[1] = file_name.length
                    data[2] = file_name 
                    packing = "CS>" + "a" + file_name.length.to_s
                    
                    #SM Send via UUT PAYLOAD_WRITE
                    click_cmd(CMD_PL_DEL_FILE, data, packing)
                end

                #TODO: Get telemetry...
            end

        elsif user_cmd == 'PL_SET_PAT_MODE'
            user_pat_mode = combo_box("Select PAT mode (or EXIT).", 
            pat_mode_names[0], pat_mode_names[1], pat_mode_names[2], pat_mode_names[3], 'EXIT')
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
        
                    #TODO: Get FGPA answer telemetry...

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

                    #TODO: Get FGPA answer telemetry...

                else
                    prompt("Request number out of bounds (0 to 255)")
                end
            end

        elsif user_cmd == 'PL_SET_HK'
            prompt("PL_SET_HK not yet implemented.")

        elsif user_cmd == 'PL_ECHO'
            user_echo_data = ask("For PL_ECHO, input string to echo. Input EXIT to escape.", 'EXIT')
            if user_echo_data != 'EXIT'
                #define data bytes
                data = []
                data[0] = user_echo_data
                packing = "a" + user_echo_data.length.to_s

                #SM Send via UUT PAYLOAD_WRITE
                click_cmd(CMD_PL_ECHO, data, packing)

                #TODO: Get echo telemetry
            end

        elsif user_cmd == 'PL_NOOP'
            #DC Send via UUT Payload Write (i.e. send CMD_ID only with empty data field)
            click_cmd(CMD_PL_NOOP)

        elsif user_cmd == 'PL_SELF_TEST'
            user_test_name = combo_box("Select test (or EXIT): ", self_test_names[0], 'EXIT')
            if self_test_names.include? user_test_name
                test_id = self_test_list[self_test_names.find_index(user_test_name)]                

                #define data bytes
                data = []
                data[0] = test_id
                packing = "C"

                #SM Send via UUT PAYLOAD_WRITE
                click_cmd(CMD_PL_SELF_TEST, data, packing)
            end

        elsif user_cmd == 'PL_DWNLINK_MODE'
            #DC Send via UUT Payload Write (i.e. send CMD_ID only with empty data field)
            click_cmd(CMD_PL_DWNLINK_MODE)

        elsif user_cmd == 'PL_DEBUG_MODE'
            #DC Send via UUT Payload Write (i.e. send CMD_ID only with empty data field)
            click_cmd(CMD_PL_DEBUG_MODE)

        end

    else #EXIT
        break 
    end
end

