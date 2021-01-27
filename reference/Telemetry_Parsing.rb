# Telemetry Parsing
# First go at tryint to parse telemetry files
# Goal is to parse the packets, merge the data, and extract image data or large files that expand more than one telemetry packet


# Start logging telemetry and commands
start_logging()

# Set up empty arrays for packet handling
transfer_id_arr = []
file_path_name_arr = []

i = 0 # start iteration count of loop- corresponds to the command sequence for acknowledgement command

id = subscribe_packet_data([['UUT', 'DWNLNK_FILE']], 40000) #subscribe to the file downlink packets

loop do
	i += 1
	packet = get_packet(id)
	# Read the individual items from the packet
	id_code = packet.read('ID_CODE')
	source_pi = packet.read('SOURCE_PI')
	source_sd = packet.read('SOURCE_SD')
	file_sequence_number = packet.read('FILE_SEQ_NUM')
	staged_tai = packet.read('STAGED_TAI')
	transfer_id = packet.read('TRANSF_ID')
	total_packets = packet.read('TOT_PACKETS')
	file_path_name = packet.read('PATH_NAME')
	file_md = packet.read('FILE_MD5')
	payload_size = packet.read('PL_SIZE')
	data = packet.read('DATA')
	checksum = packet.read('CH_SUM')
	puts 'Total Packets received for ID code ' + id_code.to_s + ': ' + total_packets.to_s
	
	# Method to calculate checksum of the received packet
	len = packet.length
	checksum_true = 0xFFFF
	packet[8..(len - 3)].each_byte {|x| checksum_true += x }
	checksum_true &= 0xFFFF
	puts checksum_true

	# Make sure packet data is accurate and we have the correct crc
	if checksum == checksum_true
		file = File.open("C:/Users/STAR_User/Desktop/COSMOS-Rev-F/outputs/logs/xb1_demi/COSMOS_Downlink_Testing/Packet#{transfer_id}.txt", 'a+') #open or create a text file with the same file path name as the downlinked file
		if transfer_id_arr.include? transfer_id # if a packet of this file has already been received
			file.puts "#{file_sequence_number}\t" + "#{data}" # add the data to the file with the corresponding file sequence number
		else 
			file.puts "Transfer ID: #{transfer_id}, Total packets expected: #{total_packets}, Payload size: #{payload_size}, Source pi: #{source_pi}, Staged time: #{staged_tai}, File MD%: #{file_md}" #add a header to the new file
			file.puts "File Sequence Number\tData" # Label the columns
			file.puts "#{file_sequence_number}\t" + "#{data}" # add the first packet of data with the corresponding file sequence number
			transfer_id_arr << transfer_id # add the new transfer id to the array
			file_path_name_arr << file_path_name
		end
		file.close
		cmd("UUT ACK with TARGET_PI #{source_pi}, CMD_SEQ #{i}, PI_REC #{source_pi}, FILE_SEQ_REC #{file_sequence_number}, TRANS_ID_REC #{transfer_id}, CH_SUM_STATUS GOOD") #Acknowledge packet received with correct crc/checksum
	else
		cmd("UUT ACK with TARGET_PI #{source_pi}, CMD_SEQ #{i}, PI_REC #{source_pi}, FILE_SEQ_REC #{file_sequence_number}, TRANS_ID_REC #{transfer_id}, CH_SUM_STATUS BAD") #Acknowledge packet received but specify bad packet
		puts 'Bad packet received'
	end
end
