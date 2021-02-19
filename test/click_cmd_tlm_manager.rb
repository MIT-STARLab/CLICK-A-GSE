#Test Script - CLICK Command and Telemetry Manager
#Assumed Path: #Cosmos::USERPATH + \procedures\CLICK-A-GSE\test\click_cmd_tlm_manager.rb

require 'FileUtils' # Pretty sure COSMOS already requires this, so this is might be unnecessary
require 'digest/md5'
load (Cosmos::USERPATH + '/procedures/CLICK-A-GSE/lib/click_cmd_tlm.rb')

test_log_dir = (Cosmos::USERPATH + "/outputs/logs/xb1_click/")
cosmos_dir = Cosmos::USERPATH

cmd_names = %w[
    PL_REBOOT
    PL_ENABLE_TIME
    PL_EXEC_FILE
    PL_LIST_FILE
    PL_AUTO_DOWNLINK_FILE
    PL_DISASSEMBLE_FILE
    PL_REQUEST_FILE_CHUNKS
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
    PL_UPDATE_ACQUISITION_PARAMS
    PL_TX_ALIGN
    PL_UPDATE_TX_OFFSETS
    PL_UPDATE_FSM_ANGLES
    PL_ENTER_PAT_MAIN
    PL_EXIT_PAT_MAIN
    PL_END_PAT_PROCESS
    PL_SET_FPGA
    PL_GET_FPGA
    PL_SET_HK
    PL_ECHO
    PL_NOOP
    PL_SELF_TEST
    PL_DWNLINK_MODE
    PL_DEBUG_MODE
    PL_UPDATE_SEED_PARAMS
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
    PAT_MODE_BUS_FEEDBACK,
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

#Subscribe to telemetry packets:
tlm_id_PL_ECHO = subscribe_packet_data([['UUT', 'PL_ECHO']], 10000) #set queue depth to 10000 (default is 1000)
tlm_id_PL_LIST_FILE = subscribe_packet_data([['UUT', 'PL_LIST_FILE']], 10000) #set queue depth to 10000 (default is 1000)
tlm_id_PL_PAT_SELF_TEST = subscribe_packet_data([['UUT', 'PL_PAT_SELF_TEST']], 10000) #set queue depth to 10000 (default is 1000)
tlm_id_PL_GET_FPGA = subscribe_packet_data([['UUT', 'PL_GET_FPGA']], 10000) #set queue depth to 10000 (default is 1000)
tlm_id_PL_ASSEMBLE_FILE = subscribe_packet_data([['UUT', 'PL_ASSEMBLE_FILE']], 10000) #set queue depth to 10000 (default is 1000)
tlm_id_PL_DL_FILE = subscribe_packet_data([['UUT', 'PL_DL_FILE']], 10000) #set queue depth to 10000 (default is 1000)
fpga_req_num = 0 #fpga request number counter
while true
    user_cmd = combo_box("Select a command (or EXIT): ", 
    cmd_names[0], cmd_names[1], cmd_names[2], cmd_names[3], cmd_names[4], cmd_names[5], 
    cmd_names[6], cmd_names[7], cmd_names[8], cmd_names[9], cmd_names[10], cmd_names[11],
    cmd_names[12], cmd_names[13], cmd_names[14], cmd_names[15], cmd_names[16], cmd_names[17], 
    cmd_names[18], cmd_names[19], cmd_names[20], cmd_names[21], cmd_names[22], cmd_names[23], 
    cmd_names[24], cmd_names[25], cmd_names[26], cmd_names[27], cmd_names[28], cmd_names[29],
    cmd_names[30], cmd_names[31], cmd_names[32],
    'TEST_MULTIPLE_ECHO', 'TEST_PAT', 'REQUEST_DIRECTORY_FILES', 'REQUEST_PAT_FILES', 'EXIT')
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
                out_to_file_cmd = message_box("For PL_EXEC_FILE, output to file? ", 'YES', 'NO', 'EXIT')
                if out_to_file_cmd == 'YES'
                    out_to_file = 0xFF
                    file_out_num = ask("For PL_EXEC_FILE, input the file output number (e.g. 1 saves output to /root/log/1.log). Input EXIT to escape.", 'EXIT')
                    execute = file_out_num != 'EXIT'
                elsif out_to_file_cmd == 'NO'
                    out_to_file = 0x00
                    file_out_num = 0
                    execute = true
                elsif out_to_file_cmd == 'EXIT'
                    execute = false
                end
                
                if execute
                  #define data bytes
                  data = []
                  data[0] = out_to_file #output script prints to file? Enable = 0xFF, Disable = 0x00
                  data[1] = file_out_num #file output number (if outputting script prints to file)
                  data[2] = file_path.length
                  data[3] = file_path 
                  packing = "C2S>" + "a" + file_path.length.to_s
  
                  #SM Send via UUT PAYLOAD_WRITE
                  click_cmd(CMD_PL_EXEC_FILE, data, packing) 
                end
            end

        elsif user_cmd == 'PL_LIST_FILE'
            #define directory path:
            directory_path = ask_string("For PL_LIST_FILE, input the directory path (e.g. '/root/test'). Input EXIT to escape.", 'EXIT')

            if directory_path != 'EXIT'
                success_bool, list_file_data, error_message = list_file(directory_path, tlm_id_PL_LIST_FILE)
                if(success_bool)
                    prompt(list_file_data)
                else
                    prompt(error_message + list_file_data)
                end
            end

        elsif user_cmd == 'PL_AUTO_DOWNLINK_FILE'
            #define file path:
            file_path = ask_string("For PL_AUTO_DOWNLINK_FILE, input the payload file path (e.g. /root/test/test_tlm.txt). Input EXIT to escape.", 'EXIT')
            #can get image name via list file command or via housekeeping tlm stream or PAT .txt telemetry file
            if file_path != 'EXIT'
                request_file(file_path, tlm_id_PL_DL_FILE)
            end

        elsif user_cmd == 'PL_DISASSEMBLE_FILE'
            #define file path:
            file_path = ask_string("For PL_DISASSEMBLE_FILE, input the payload file path (e.g. /root/test/test_tlm.txt). Input EXIT to escape.", 'EXIT')
            #can get image name via list file command or via housekeeping tlm stream or PAT .txt telemetry file
            if file_path != 'EXIT'
                #Send command
                disassemble_file(trans_id, file_path)
            end

        elsif user_cmd == 'PL_REQUEST_FILE_CHUNKS'
            transfer_id = ask("For PL_ASSEMBLE_FILE, input the transfer id (use list file cmd on /root/file_staging to see available ids). Input EXIT to escape.", 'EXIT')
            if transfer_id != 'EXIT'
                all_chunks_cmd = message_box("For PL_REQUEST_FILE_CHUNKS, request all file chunks? ", 'YES', 'NO', 'EXIT')
                if all_chunks_cmd == 'YES'
                    request_file_chunks(transfer_id, true)
                elsif all_chunks_cmd == 'NO'
                    chunk_start_idx = ask("For PL_REQUEST_FILE_CHUNKS, input the chunk start index. Input EXIT to escape.", 'EXIT')
                    if chunk_start_idx != 'EXIT'
                        num_chunks = ask("For PL_REQUEST_FILE_CHUNKS, input the number of chunks. Input EXIT to escape.", 'EXIT')
                        if num_chunks != 'EXIT'
                            request_file_chunks(transfer_id, false, chunk_start_idx, num_chunks)
                        end
                    end
                end
            end

        elsif user_cmd == 'PL_UPLOAD_FILE'
            upload_file(tlm_id_PL_ASSEMBLE_FILE) #prompts user via file explorer to select file to upload, then walks user through sequence

        elsif user_cmd == 'PL_ASSEMBLE_FILE'
            file_name = ask_string("For PL_ASSEMBLE_FILE, input the payload file path (e.g. test_file_transfer.txt). Input EXIT to escape.", 'EXIT') 
            if file_name != 'EXIT'
                transfer_id = ask("For PL_ASSEMBLE_FILE, input the transfer id (use list file cmd on /root/file_staging to see available ids). Input EXIT to escape.", 'EXIT')
                if transfer_id != 'EXIT'
                    file_path = "/root/file_staging/" + transfer_id.to_s + "/" + file_name
                    assemble_file(transfer_id, file_path)
                end
            end

        elsif user_cmd == 'PL_VALIDATE_FILE'
            file_name = ask_string("For PL_VALIDATE_FILE, input the payload file path (e.g. /root/commandhandler/test_file.txt). Input EXIT to escape.", 'EXIT')
            if file_name != 'EXIT'
                md5 = Digest::MD5.file file_name
                validate_file(md5, payload_file_path_staging)
            end

        elsif user_cmd == 'PL_MOVE_FILE'
            source_file_path = ask_string("For PL_MOVE_FILE, input the file source path (e.g. '/root/test/test_tlm.txt'). Input EXIT to escape.", 'EXIT')
            if source_file_path != 'EXIT'
                destination_file_path = ask_string("For PL_MOVE_FILE, input the file destination path (e.g. '/root/log/test_tlm.txt'). Input EXIT to escape.", 'EXIT')
                if destination_file_path != 'EXIT'
                    move_file(source_file_path, destination_file_path)
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
                end
            end

        elsif user_cmd == 'PL_SET_PAT_MODE'
            user_pat_mode = combo_box("Select PAT mode (or EXIT).", 
            pat_mode_names[0], pat_mode_names[1], pat_mode_names[2], pat_mode_names[3], pat_mode_names[4], pat_mode_names[5], 'EXIT')
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
            user_window_width = ask("For PL_SINGLE_CAPTURE, input window width in pixels. Options: Input FULL for full frame. Input DEFAULT for default centered 600x600 window. Input EXIT to escape.", 'EXIT')
            if user_window_width != 'EXIT'
                if user_window_width == 'FULL'
                    user_exp = ask("For PL_SINGLE_CAPTURE, input maximum beacon exposure time (us) (between 10 and 10000000). Input EXIT to escape.", 'EXIT')
                    if user_exp != 'EXIT'
                        if user_exp >= CAMERA_MIN_EXP and user_exp <= CAMERA_MAX_EXP
                            #define data bytes
                            data = []
                            data[0] = 0 #window center X relative to center
                            data[1] = 0 #window center Y relative to center
                            data[2] = CAMERA_WIDTH
                            data[3] = CAMERA_HEIGHT
                            data[4] = user_exp
                            packing = "s>2S>2L>"

                            #SM Send via UUT Payload Write
                            click_cmd(CMD_PL_SINGLE_CAPTURE, data, packing)

                            #Get image telemetry
                            get_img_cmd = message_box("Get image now?", 'YES', 'NO')
                            if get_img_cmd == 'YES'
                                request_pat_telemetry(tlm_id_PL_LIST_FILE, tlm_id_PL_DL_FILE)
                            end
                        else
                            prompt("Exposure time out of bounds (10 to 10000000).")
                        end
                    end

                elsif user_window_width == 'DEFAULT'
                    user_exp = ask("For PL_SINGLE_CAPTURE, input maximum beacon exposure time (us) (between 10 and 10000000). Input EXIT to escape.", 'EXIT')
                    if user_exp != 'EXIT'
                        if user_exp >= CAMERA_MIN_EXP and user_exp <= CAMERA_MAX_EXP
                            #define data bytes
                            data = []
                            data[0] = 0 #window center X relative to center
                            data[1] = 0 #window center Y relative to center
                            data[2] = 600
                            data[3] = 600
                            data[4] = user_exp
                            packing = "s>2S>2L>"

                            #SM Send via UUT Payload Write
                            click_cmd(CMD_PL_SINGLE_CAPTURE, data, packing)

                            #Get image telemetry
                            get_img_cmd = message_box("Get image now?", 'YES', 'NO')
                            if get_img_cmd == 'YES'
                                request_pat_telemetry(tlm_id_PL_LIST_FILE, tlm_id_PL_DL_FILE)
                            end
                        else
                            prompt("Exposure time out of bounds (10 to 10000000).")
                        end
                    end

                elsif user_window_width <= CAMERA_WIDTH
                    user_window_height = ask("For PL_SINGLE_CAPTURE, input window height in pixels. Options: Input SQUARE for square window. Input EXIT to escape.", 'EXIT')
                    if user_window_height != 'EXIT'
                        if user_window_height == 'SQUARE'
                            user_window_height = user_window_width
                        end
                        if user_window_height <= CAMERA_HEIGHT
                            user_window_ctr_rel_x = ask("For PL_SINGLE_CAPTURE, input window center X relative position in pixels. Input EXIT to escape.", 'EXIT')
                            if user_window_ctr_rel_x != 'EXIT'
                                user_window_ctr_rel_y = ask("For PL_SINGLE_CAPTURE, input window center Y relative position in pixels. Input EXIT to escape.", 'EXIT')
                                if user_window_ctr_rel_y != 'EXIT'
                                    if user_window_ctr_rel_x <= CAMERA_WIDTH/2 - user_window_width/2 and user_window_ctr_rel_y <= CAMERA_HEIGHT/2 - user_window_height/2
                                        user_exp = ask("For PL_SINGLE_CAPTURE, input exposure time (us) (between 10 and 10000000). Input EXIT to escape.", 'EXIT')
                                        if user_exp != 'EXIT'
                                            if user_exp >= CAMERA_MIN_EXP and user_exp <= CAMERA_MAX_EXP
                                                #define data
                                                data = []
                                                data[0] = user_window_ctr_rel_x
                                                data[1] = user_window_ctr_rel_y
                                                data[2] = user_window_width
                                                data[3] = user_window_height
                                                data[4] = user_exp
                                                packing = "s>2S>2L>"
                            
                                                #SM Send via UUT Payload Write
                                                click_cmd(CMD_PL_SINGLE_CAPTURE, data, packing)

                                                #Get image telemetry
                                                get_img_cmd = message_box("Get image now?", 'YES', 'NO')
                                                if get_img_cmd == 'YES'
                                                    request_pat_telemetry(tlm_id_PL_LIST_FILE, tlm_id_PL_DL_FILE)
                                                end
                                            else
                                                prompt("Exposure time out of bounds (10 to 10000000).")
                                            end
                                        end
                                    else
                                        prompt("Beacon relative position out of bounds.")
                                    end
                                end
                            end
                        else
                            prompt("Beacon window size out of bounds.") 
                        end
                    end
                else
                    prompt("Beacon window size out of bounds.")
                end
            end   

        elsif user_cmd == 'PL_CALIB_LASER_TEST'
            user_exp = ask("For PL_CALIB_LASER_TEST, input exposure time (us) (between 10 and 10000000). Input EXIT to escape.", 'EXIT')
            if user_exp != 'EXIT'
                if user_exp >= CAMERA_MIN_EXP and user_exp <= CAMERA_MAX_EXP
                    #define data bytes
                    data = []
                    data[0] = user_exp
                    packing = "L>"

                    #SM Send via UUT Payload Write
                    click_cmd(CMD_PL_CALIB_LASER_TEST, data, packing)
                else
                    prompt("Exposure time out of bounds (10 to 10000000).")
                end
            end

        elsif user_cmd == 'PL_FSM_TEST'
            user_exp = ask("For PL_FSM_TEST, input exposure time (us) (between 10 and 10000000). Input EXIT to escape.", 'EXIT')
            if user_exp != 'EXIT'
                if user_exp >= CAMERA_MIN_EXP and user_exp <= CAMERA_MAX_EXP
                    #define data bytes
                    data = []
                    data[0] = user_exp
                    packing = "L>"

                    #SM Send via UUT Payload Write
                    click_cmd(CMD_PL_FSM_TEST, data, packing)
                else
                    prompt("Exposure time out of bounds (10 to 10000000).")
                end
            end

        elsif user_cmd == 'PL_RUN_CALIBRATION'
            #DC Send via UUT Payload Write (i.e. send CMD_ID only with empty data field)
            click_cmd(CMD_PL_RUN_CALIBRATION)
        
        elsif user_cmd == 'PL_UPDATE_ACQUISITION_PARAMS'
            user_bcn_window_size = ask("For PL_UPDATE_ACQUISITION_PARAMS, input beacon acquisition window size (width = height) in pixels. Input EXIT to escape.", 'EXIT')
            if user_bcn_window_size != 'EXIT'
                if user_bcn_window_size <= CAMERA_HEIGHT
                    user_bcn_rel_x = ask("For PL_UPDATE_ACQUISITION_PARAMS, input beacon X relative position in pixels. Input EXIT to escape.", 'EXIT')
                    if user_bcn_rel_x != 'EXIT'
                        user_bcn_rel_y = ask("For PL_UPDATE_ACQUISITION_PARAMS, input beacon Y relative position in pixels. Input EXIT to escape.", 'EXIT')
                        if user_bcn_rel_y != 'EXIT'
                            if user_bcn_rel_x <= CAMERA_WIDTH/2 - user_bcn_window_size/2 and user_bcn_rel_y <= CAMERA_HEIGHT/2 - user_bcn_window_size/2
                                user_bcn_max_exp = ask("For PL_UPDATE_ACQUISITION_PARAMS, input maximum beacon exposure time (us) (between 10 and 10000000). Input EXIT to escape.", 'EXIT')
                                if user_bcn_max_exp != 'EXIT'
                                    if user_bcn_max_exp >= CAMERA_MIN_EXP and user_bcn_max_exp <= CAMERA_MAX_EXP
                                        #define data bytes
                                        data = []
                                        data[0] = user_bcn_rel_x
                                        data[1] = user_bcn_rel_y
                                        data[3] = user_bcn_window_size
                                        data[4] = user_bcn_max_exp
                                        packing = "s>2S>L>"
                    
                                        #SM Send via UUT Payload Write
                                        click_cmd(CMD_PL_UPDATE_ACQUISITION_PARAMS, data, packing)
                                    else
                                        prompt("Exposure time out of bounds (10 to 10000000).")
                                    end
                                end
                            else
                                prompt("Beacon relative position out of bounds.")
                            end
                        end
                    else
                        prompt("Beacon window size out of bounds.") 
                    end
                end
            end            

        elsif user_cmd == 'PL_TX_ALIGN'
            #DC Send via UUT Payload Write (i.e. send CMD_ID only with empty data field)
            click_cmd(CMD_PL_TX_ALIGN)
            
        elsif user_cmd == 'PL_UPDATE_TX_OFFSETS'
            user_x_update = ask("For PL_UPDATE_TX_OFFSETS, input X displacement in pixels (or 0). Input EXIT to escape.", 'EXIT')
            if user_x_update != 'EXIT'
                user_y_update = ask("For PL_UPDATE_TX_OFFSETS, input Y displacement in pixels (or 0). Input EXIT to escape.", 'EXIT')
                if user_y_update != 'EXIT'
                    if user_x_update <= CAMERA_WIDTH/2 and user_y_update <= CAMERA_HEIGHT/2
                        user_config_cmd = message_box('For PL_UPDATE_TX_OFFSETS, configure tx offset thermal model update period or enable dithering? (PAT must be in STANDBY)', 'YES', 'NO')
                        if user_config_cmd == 'NO'
                            tx_offset_calc_pd = 1000
                            enable_dither = 0
                            dither_pd = 10
                        else
                            tx_offset_calc_pd = ask('For PL_UPDATE_TX_OFFSETS, input Tx Offset thermal model re-calculation period in seconds (e.g. 1000).')
                            enable_dither_cmd = message_box('For PL_UPDATE_TX_OFFSETS, enable Tx Offset dithering?', 'YES', 'NO')
                            if enable_dither_cmd == 'YES'
                                enable_dither = 0xFF
                                dither_pd = ask('For PL_UPDATE_TX_OFFSETS, input dithering period in seconds (e.g. 10).')
                            else
                                enable_dither = 0
                                dither_pd = 10
                            end
                        end
                        #define data bytes
                        data = []
                        data[0] = user_x_update
                        data[1] = user_y_update
                        data[2] = tx_offset_calc_pd
                        data[3] = enable_dither
                        data[4] = dither_pd
                        packing = "s>2S>CS>"
    
                        #SM Send via UUT Payload Write
                        click_cmd(CMD_PL_UPDATE_TX_OFFSETS, data, packing)
                    else
                        prompt("Displacement out of bounds (< 1000 pixels).")
                    end
                end
            end
            
        elsif user_cmd == 'PL_UPDATE_FSM_ANGLES'
            user_x_update = ask("For PL_UPDATE_FSM_ANGLES, input X displacement in pixels (or 0). Input EXIT to escape.", 'EXIT')
            if user_x_update != 'EXIT'
                user_y_update = ask("For PL_UPDATE_FSM_ANGLES, input Y displacement in pixels (or 0). Input EXIT to escape.", 'EXIT')
                if user_y_update != 'EXIT'
                    if user_x_update <= 1000 and user_y_update <= 1000
                        #define data bytes
                        data = []
                        data[0] = user_x_update
                        data[1] = user_y_update
                        packing = "s>2"
    
                        #SM Send via UUT Payload Write
                        click_cmd(CMD_PL_UPDATE_FSM_ANGLES, data, packing)
                    else
                        prompt("Displacement out of bounds (< 1000 pixels).")
                    end
                end
            end

        elsif user_cmd == 'PL_ENTER_PAT_MAIN'
            #Start Main Pat Loop via DC Send via UUT Payload Write (i.e. send CMD_ID only with empty data field)
            click_cmd(CMD_PL_ENTER_PAT_MAIN)
            
        elsif user_cmd == 'PL_EXIT_PAT_MAIN'
            #DC Send via UUT Payload Write (i.e. send CMD_ID only with empty data field)
            click_cmd(CMD_PL_EXIT_PAT_MAIN)

        elsif user_cmd == 'PL_END_PAT_PROCESS'
            #DC Send via UUT Payload Write (i.e. send CMD_ID only with empty data field)
            click_cmd(CMD_PL_END_PAT_PROCESS)

        elsif user_cmd == 'PL_SET_FPGA'
            #define request number, start address, and data to write
            user_start_address = ask("For PL_SET_FPGA, input start register address. Input EXIT to escape.", 'EXIT')
            if user_start_address != 'EXIT'
                user_num_registers = ask("For PL_SET_FPGA, input number of registers to write.")
                fpga_req_num = (fpga_req_num + 1)%256
                user_write_data = []
                for i in 0..(user_num_registers-1)
                    user_write_data_i = ask("For PL_SET_FPGA, input data to write to register " + (user_start_address + i).to_s)
                    user_write_data += [user_write_data_i] 
                end               
                
                #define data bytes
                data = []
                data[0] = fpga_req_num
                data[1] = user_start_address
                data[2] = user_write_data.length
                data += user_write_data
                packing = "CS>C" + "L>" + user_write_data.length.to_s
    
                #SM Send via UUT PAYLOAD_WRITE
                click_cmd(CMD_PL_SET_FPGA, data, packing)
            end

        elsif user_cmd == 'PL_GET_FPGA'
            #define request number, start address, and data to write
            user_start_address = ask("For PL_GET_FPGA, input start register address. Input EXIT to escape.", 'EXIT')
            if user_start_address != 'EXIT'
                user_num_registers = ask("For PL_GET_FPGA, input number of registers to read.")         
                fpga_req_num = (fpga_req_num + 1)%256
                #define data bytes
                data = []
                data[0] = fpga_req_num
                data[1] = user_start_address
                data[2] = user_num_registers
                packing = "CS>C"

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
                
                request_num_check = fpga_req_num == request_num_rx
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
                if !start_addr_check
                    summary_message += ("Request Number Error! Received start address (= " + start_addr_check.to_s + ") not equal to transmitted start address (= " + user_start_address.to_s + ").\n")
                end
                if !num_registers_check
                    summary_message += ("Request Number Error! Received number of registers (= " + num_registers_rx.to_s + ") not equal to requested number of registers (= " + user_num_registers.to_s + ").\n")
                end
                summary_message += "Read Data: \n"
                if num_registers_rx > 1
                    for i in 0..(num_registers_rx-1)
                        register = start_addr_rx + i
                        summary_message += ("Register: " + register.to_s + ", Value: " + read_data[i].to_s + "\n")
                    end
                else
                    summary_message += ("Register: " + start_addr_rx.to_s + ", Value: " + read_data.to_s + "\n")
                end
                prompt(summary_message)
            end

        elsif user_cmd == 'PL_SET_HK'
            all_packets_enable = message_box('For PL_SET_HK, enable all packets? [Default]', 'YES', 'NO')
            enable_str = '00000000'
            if all_packets_enable == 'YES'
                enable_str[0] = '1'
            else
                enable_str[1] = message_box('For PL_SET_HK, click 1 to enable FPGA requests.', '1', '0')
                enable_str[2] = message_box('For PL_SET_HK, click 1 to enable FPGA requests.', '1', '0')
                enable_str[3] = message_box('For PL_SET_HK, click 1 to enable FPGA housekeeping message sending.', '1', '0')
                enable_str[4] = message_box('For PL_SET_HK, click 1 to enable PAT housekeeping message sending.', '1', '0')
                enable_str[5] = message_box('For PL_SET_HK, click 1 to enable command handler restart.', '1', '0')
                enable_str[6] = message_box('For PL_SET_HK, click 1 to enable PAT restart.', '1', '0')
                enable_str[7] = message_box('For PL_SET_HK, click 1 to enable FPGA restart.', '1', '0')
            end
            enable_byte = ('0b' + enable_str).to_i(2)

            fpga_heartbeat_period = ask('For PL_SET_HK, enter FPGA heartbeat period in seconds.')
            system_heartbeat_period = ask('For PL_SET_HK, enter System heartbeat period in seconds.')
            ch_heartbeat_period = ask('For PL_SET_HK, enter Commandhandler heartbeat period in seconds.')
            pat_heartbeat_period = ask('For PL_SET_HK, enter PAT heartbeat period in seconds.')
            
            data = []
            data[0] = enable_byte
            data[1] = fpga_heartbeat_period
            data[2] = system_heartbeat_period
            data[3] = ch_heartbeat_period
            data[4] = pat_heartbeat_period
            packing = "C*"
            click_cmd(CMD_PL_SET_HK, data, packing)

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

                #Get Telemetry:
                if test_id == GENERAL_SELF_TEST
                    prompt("PL_GENERAL_SELF_TEST command sent. Use file transfer to retrieve log data.") ###TODO automate this

                elsif test_id == LASER_SELF_TEST
                    prompt("PL_LASER_SELF_TEST command sent. Use file transfer to retrieve log data.") ###TODO automate this

                elsif test_id == PAT_SELF_TEST
                    getResults_PAT_SELF_TEST(test_log_dir, tlm_id_PL_PAT_SELF_TEST, tlm_id_PL_LIST_FILE, tlm_id_PL_DL_FILE)
                end
            end

        elsif user_cmd == 'PL_DWNLINK_MODE'
            #DC Send via UUT Payload Write (i.e. send CMD_ID only with empty data field)
            click_cmd(CMD_PL_DWNLINK_MODE)

            #Display PAT Self Test Results
            getResults_PAT_SELF_TEST(test_log_dir, tlm_id_PL_PAT_SELF_TEST, tlm_id_PL_LIST_FILE, tlm_id_PL_DL_FILE)

            #Get full PAT test data
            prompt("Test is running...\nWhen complete, press Continue to restart PAT process and retrieve log data.")
            request_pat_telemetry(tlm_id_PL_LIST_FILE, tlm_id_PL_DL_FILE)

            #Get remainder of data (TODO: automate this)
            prompt("Use file transfer to retrieve remaining test log data.")

        elsif user_cmd == 'PL_DEBUG_MODE'
            #DC Send via UUT Payload Write (i.e. send CMD_ID only with empty data field)
            click_cmd(CMD_PL_DEBUG_MODE)

        elsif user_cmd == 'PL_UPDATE_SEED_PARAMS'
            prompt('PL_UPDATE_SEED_PARAMS not yet implemented.')

        end

    elsif user_cmd == 'TEST_MULTIPLE_ECHO'
        num_echo_tests = ask("For TEST_MULTIPLE_ECHO, enter number of echo tests to perform: ")
        current_timestamp, current_time_str = get_timestamp()
        
        #Run test
        num_errors, message_list = multiple_echo_test(num_echo_tests, tlm_id_PL_ECHO)

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

    elsif user_cmd == 'TEST_PAT'
        prompt("Ensure PAT Health Telemetry stream is running before proceeding (i.e. run test_hk_pat_tlm.rb in a separate window).\n Press Continue to execute calibration.")

        #Run PAT Self Test
        test_id = PAT_SELF_TEST             
        #define data bytes
        data = []
        data[0] = test_id
        packing = "C"
        #SM Send via UUT PAYLOAD_WRITE
        click_cmd(CMD_PL_SELF_TEST, data, packing)

        #Display PAT Self Test Results
        getResults_PAT_SELF_TEST(test_log_dir, tlm_id_PL_PAT_SELF_TEST, tlm_id_PL_LIST_FILE, tlm_id_PL_DL_FILE)

        #Turn on Beacon (User Prompt)
        prompt("Turn ON Beacon Laser via GSE AlphaNov program before proceeding.")

        #Start Main Pat Loop via DC Send via UUT Payload Write (i.e. send CMD_ID only with empty data field)
        click_cmd(CMD_PL_ENTER_PAT_MAIN)

        #Turn on Dithering (User Prompt)
        prompt("1. Start Beacon Dithering via CSV command on GSE GUI.\n2. Wait for dithering script to complete.")
        
        #Return PAT to standby 
        click_cmd(CMD_PL_EXIT_PAT_MAIN)
        
        prompt("Press Continue to restart PAT and retrieve test telemetry.")
        
        #Restart PAT and get most recent PAT telemetry data
        request_pat_telemetry(tlm_id_PL_LIST_FILE, tlm_id_PL_DL_FILE)
    
    elsif user_cmd == 'REQUEST_DIRECTORY_FILES'
        #define directory path:
        directory_path = ask_string("For REQUEST_DIRECTORY_FILES, input the payload directory path (e.g. '/root/log/pat/<experiment id>'). Input EXIT to escape.", 'EXIT')

        if directory_path != 'EXIT'
            request_directory_files(directory_path, tlm_id_PL_LIST_FILE, tlm_id_PL_DL_FILE)
        end

    elsif user_cmd == 'REQUEST_PAT_FILES'
        #define directory path:
        exp_id_str = ask_string("For REQUEST_PAT_FILES, input the experiment id number (i.e. the desired directory number in /root/log/pat). Input EXIT to escape.", 'EXIT')

        if exp_id_str != 'EXIT'
            request_pat_telemetry(tlm_id_PL_LIST_FILE, tlm_id_PL_DL_FILE, exp_id_str)
        end   

    else #EXIT
        break 
    end
end

