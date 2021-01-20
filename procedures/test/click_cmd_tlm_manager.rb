#Test Script - CLICK Command and Telemetry Manager
#Assumed Path: #C:\BCT\71sw0078_a_cosmos_click_edu\procedures\test\click_cmd_tlm_manager.rb

require 'FileUtils' # Pretty sure COSMOS already requires this, so this is might be unnecessary
require 'digest/md5'
load 'C:/BCT/71sw0078_a_cosmos_click_edu/procedures/lib/pl_cmd_tlm_apids.rb'
load 'C:/BCT/71sw0078_a_cosmos_click_edu/procedures/lib/click_cmd.rb'

cmd_list = %w[
    CMD_PL_REBOOT
    CMD_PL_ENABLE_TIME
    CMD_PL_DISABLE_TIME
    CMD_PL_EXEC_FILE
    CMD_PL_LIST_FILE
    CMD_PL_REQUEST_FILE
    CMD_PL_UPLOAD_FILE
    CMD_PL_ASSEMBLE_FILE
    CMD_PL_VALIDATE_FILE
    CMD_PL_MOVE_FILE
    CMD_PL_DEL_FILE
    CMD_PL_SET_PAT_MODE
    CMD_PL_SINGLE_CAPTURE
    CMD_PL_CALIB_LASER_TEST
    CMD_PL_FSM_TEST
    CMD_PL_RUN_CALIBRATION
    CMD_PL_SET_FPGA
    CMD_PL_GET_FPGA
    CMD_PL_SET_HK
    CMD_PL_ECHO
    CMD_PL_NOOP
    CMD_PL_SELF_TEST
    CMD_PL_DWNLINK_MODE
    CMD_PL_DEBUG_MODE
]

cmd_names = %w[
    'PL_REBOOT'
    'PL_ENABLE_TIME'
    'PL_DISABLE_TIME'
    'PL_EXEC_FILE'
    'PL_LIST_FILE'
    'PL_REQUEST_FILE'
    'PL_UPLOAD_FILE'
    'PL_ASSEMBLE_FILE'
    'PL_VALIDATE_FILE'
    'PL_MOVE_FILE'
    'PL_DEL_FILE'
    'PL_SET_PAT_MODE'
    'PL_SINGLE_CAPTURE'
    'PL_CALIB_LASER_TEST'
    'PL_FSM_TEST'
    'PL_RUN_CALIBRATION'
    'PL_SET_FPGA'
    'PL_GET_FPGA'
    'PL_SET_HK'
    'PL_ECHO'
    'PL_NOOP'
    'PL_SELF_TEST'
    'PL_DWNLINK_MODE'
    'PL_DEBUG_MODE'
]

self_test_list = %w[
    TEST_PAT_HW
]

self_test_names = %w[
    'PAT_HW'
]

pat_mode_list = %w[
    PAT_MODE_DEFAULT
    PAT_MODE_OPEN_LOOP
    PAT_MODE_STATIC_POINTING
    PAT_MODE_BUS_FEEDBACK
]

pat_mode_names = %w[
    'DEFAULT'
    'OPEN_LOOP'
    'STATIC_POINTING'
    'BUS_FEEDBACK'
]

while true
    puts "Available Commands: "
    puts cmd_names
    puts "Enter a command: "
    user_cmd = gets.chomp 
    if cmd_names.include? user_cmd
        if user_cmd == 'PL_REBOOT'
            puts 'Executing ' + user_cmd + '...'
            #DC Send via UUT Payload Write (i.e. send CMD_ID only with empty data field)
            click_cmd(CMD_PL_REBOOT)

        elsif user_cmd == 'PL_ENABLE_TIME'
            puts 'Executing ' + user_cmd + '...'
            #DC Send via UUT Payload Write (i.e. send CMD_ID only with empty data field)
            click_cmd(CMD_PL_ENABLE_TIME)

        elsif user_cmd == 'PL_DISABLE_TIME'
            puts 'Executing ' + user_cmd + '...'
            #DC Send via UUT Payload Write (i.e. send CMD_ID only with empty data field)
            click_cmd(CMD_PL_DISABLE_TIME)

        elsif user_cmd == 'PL_EXEC_FILE'
            #define file path:
            puts "For PL_EXEC_FILE, input the payload file path (e.g. /root/bin/pat): "
            file_path = gets.chomp 

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

        elsif user_cmd == 'PL_LIST_FILE'
            #define directory path:
            puts "For PL_LIST_FILE, input the directory path (e.g. /root/bin): "
            directory_path = gets.chomp 

            #define data bytes
            data = []
            data[0] = directory_path.length
            data[1] = directory_path 
            packing = "C" + "a" + directory_path.length.to_s

            #SM Send via UUT PAYLOAD_WRITE
            click_cmd(CMD_PL_LIST_FILE, data, packing)

            #TODO: Get file list telemetry...

        elsif user_cmd == 'PL_REQUEST_FILE'
            #define file path:
            puts "For PL_REQUEST_FILE, input the payload file path (e.g. /root/log/pat/img_file_name.png): "
            file_path = gets.chomp  #can get image name via list file command or via housekeeping tlm stream or PAT .txt telemetry file

            #define data bytes
            data = []
            data[0] = file_path.length
            data[1] = file_path 
            packing = "C" + "a" + file_path.length.to_s

            #SM Send via UUT PAYLOAD_WRITE
            click_cmd(CMD_PL_REQUEST_FILE, data, packing)

            #TODO: Get file telemetry...

        elsif user_cmd == 'PL_UPLOAD_FILE'
            ###TODO... maybe just call test_upload_file.rb
            puts 'PL_UPLOAD_FILE not yet implemented.'

        elsif user_cmd == 'PL_ASSEMBLE_FILE'
            puts "For PL_ASSEMBLE_FILE, input the payload file name (e.g. pat): "
            file_name = gets.chomp #TBR (should it just be the file name or the whole path?)
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

        elsif user_cmd == 'PL_VALIDATE_FILE'
            puts "For PL_VALIDATE_FILE, input the payload file name (e.g. pat): "
            file_name = gets.chomp #TBR (should it just be the file name or the whole path?)
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

        elsif user_cmd == 'PL_MOVE_FILE'
            puts "For PL_MOVE_FILE, input the file source path (e.g. '/root/bin/pat'): "
            source_file_name = gets.chomp
            puts "For PL_MOVE_FILE, input the file destination path (e.g. '/root/pat'): "
            destination_file_name = gets.chomp
            
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

        elsif user_cmd == 'PL_DEL_FILE'
            puts "For PL_DEL_FILE, input the file path (e.g. '/root/bin/pat'): " #TBR path or name?
            file_name = gets.chomp
            puts "For PL_DEL_FILE, recursive delete? (Y/n): "
            recursive_cmd = gets.chomp
            if recursive_cmd == "Y"
                recursive = 0xFF
                execute = true
            elsif recursive_cmd == "n"
                recursive = 0x00
                execute = true
            else
                puts "Unrecognized recursive command: " + recursive_cmd
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

        elsif user_cmd == 'PL_SET_PAT_MODE'
            puts "For PL_SET_PAT_MODE, available modes are: "
            puts pat_mode_names
            puts "Enter PAT mode: "
            user_pat_mode = gets.chomp 
            if pat_mode_names.include? user_pat_mode
                pat_mode = pat_mode_list[pat_mode_names.find_index(user_pat_mode)]                

                #define data bytes
                data = []
                data[0] = pat_mode
                packing = "C"

                #SM Send via UUT PAYLOAD_WRITE
                click_cmd(CMD_PL_SET_PAT_MODE, data, packing)
            else
                puts "Unrecognized PAT mode: " + user_pat_mode
            end

        elsif user_cmd == 'PL_SINGLE_CAPTURE'
            puts "For PL_SINGLE_CAPTURE, input exposure time (us) (between 10 and 10000000): "
            user_exp = gets.chomp.to_i 
            if user_exp >= 10 and user_exp <= 10000000
                #define data bytes
                data = []
                data[0] = user_exp
                packing = "L>"

                #SM Send via UUT Payload Write
                click_cmd(CMD_PL_SINGLE_CAPTURE, data, packing)

                #TODO: Get image telemetry

            else
                puts "Exposure time out of bounds (between 10 and 10000000)."
            end

        elsif user_cmd == 'PL_CALIB_LASER_TEST'
            puts "For PL_CALIB_LASER_TEST, input exposure time (us) (between 10 and 10000000): "
            user_exp = gets.chomp.to_i 
            if user_exp >= 10 and user_exp <= 10000000
                #define data bytes
                data = []
                data[0] = user_exp
                packing = "L>"

                #SM Send via UUT Payload Write
                click_cmd(CMD_PL_CALIB_LASER_TEST, data, packing)

                #TODO: Get image telemetry

            else
                puts "Exposure time out of bounds (between 10 and 10000000)."
            end

        elsif user_cmd == 'PL_FSM_TEST'
            puts "For PL_FSM_TEST, input exposure time (us) (between 10 and 10000000): "
            user_exp = gets.chomp.to_i 
            if user_exp >= 10 and user_exp <= 10000000
                #define data bytes
                data = []
                data[0] = user_exp
                packing = "L>"

                #SM Send via UUT Payload Write
                click_cmd(CMD_PL_FSM_TEST, data, packing)

                #TODO: Get image telemetry

            else
                puts "Exposure time out of bounds (10 to 10000000)."
            end

        elsif user_cmd == 'PL_RUN_CALIBRATION'
            puts 'Executing ' + user_cmd + '...'
            #DC Send via UUT Payload Write (i.e. send CMD_ID only with empty data field)
            click_cmd(CMD_PL_RUN_CALIBRATION)

        elsif user_cmd == 'PL_SET_FPGA'
            #define request number, start address, and data to write
            puts "For PL_SET_FPGA, input request number (between 0 and 255): "
            user_request_number = gets.chomp.to_i 
            if user_request_number >= 0 and user_request_number <= 255
                puts "For PL_SET_FPGA, input start register address: "
                user_start_address = gets.chomp.to_i 
                puts "For PL_SET_FPGA, input number of registers to write: "
                user_num_registers = gets.chomp.to_i 
                user_write_data = []
                for i in 0..(user_num_registers-1)
                    puts "For PL_SET_FPGA, input data to write to register #{start_address + i}: "
                    user_write_data += [gets.chomp.to_i] 
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
                puts "Request number out of bounds (0 to 255)"
            end

        elsif user_cmd == 'PL_GET_FPGA'
            #define request number, start address, and data to write
            puts "For PL_GET_FPGA, input request number (between 0 and 255): "
            user_request_number = gets.chomp.to_i 
            if user_request_number >= 0 and user_request_number <= 255
                puts "For PL_GET_FPGA, input start register address: "
                user_start_address = gets.chomp.to_i 
                puts "For PL_GET_FPGA, input number of registers to read: "
                user_num_registers = gets.chomp.to_i            

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
                puts "Request number out of bounds (0 to 255)"
            end

        elsif user_cmd == 'PL_SET_HK'
            puts "PL_SET_HK not yet implemented."

        elsif user_cmd == 'PL_ECHO'
            puts "For PL_ECHO, input string to echo: "
            user_echo_data = gets.chomp

            #define data bytes
            data = []
            data[0] = user_echo_data
            packing = "a" + user_echo_data.length.to_s

            #SM Send via UUT PAYLOAD_WRITE
            click_cmd(CMD_PL_ECHO, data, packing)

            #TODO: Get echo telemetry

        elsif user_cmd == 'PL_NOOP'
            puts 'Executing ' + user_cmd + '...' 
            #DC Send via UUT Payload Write (i.e. send CMD_ID only with empty data field)
            click_cmd(CMD_PL_NOOP)

        elsif user_cmd == 'PL_SELF_TEST'
            puts "For PL_SELF_TEST, available tests are: "
            puts self_test_names
            puts "Enter test: "
            user_test_name = gets.chomp 
            if self_test_names.include? user_test_name
                test_id = self_test_list[self_test_names.find_index(user_test_name)]                

            #define data bytes
            data = []
            data[0] = test_id
            packing = "C"

            #SM Send via UUT PAYLOAD_WRITE
            click_cmd(CMD_PL_SELF_TEST, data, packing)

            else
                puts "Unrecognized test: " + user_test_name
            end

        elsif user_cmd == 'PL_DWNLINK_MODE'
            puts 'Executing ' + user_cmd + '...'
            #DC Send via UUT Payload Write (i.e. send CMD_ID only with empty data field)
            click_cmd(CMD_PL_DWNLINK_MODE)

        elsif user_cmd == 'PL_DEBUG_MODE'
            puts 'Executing ' + user_cmd + '...'
            #DC Send via UUT Payload Write (i.e. send CMD_ID only with empty data field)
            click_cmd(CMD_PL_DEBUG_MODE)

        end
    else
        puts 'Unrecognized Command: ' + user_cmd
    end
end

