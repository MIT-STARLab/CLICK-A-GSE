#Downlink Ruby Script (maybe a protocol, maybe implement in Interface class)

module Cosmos
	class DownlinkProtocol < Protocol

		def read_packet(packet)
			id_code = packet.read('ID_CODE')
			
			if id_code == 0xA4
				# Read the packet information
				source_pi = packet.read('SOURCE_PI')
				file_seq_num = packet.read('FILE_SEQ_NUM')
				staged_tai = packet.read('STAGED_TAI')
				transfer_id = packet.read('TRANSF_ID')
				total_packets = packet.read('TOT_PACKETS')
				file_path_name = packet.read('PATH_NAME')
				file_md = packet.read('FILE_MD5')
				payload_size = packet.read('PL_SIZE')
				data = packet.read('DATA')
				checksum = packet.read('CH_SUM')

				#Add the packet information to a file
				info_file = File.open("C:/Users/STAR_User/Desktop/Image#{transfer_id}-Information}.txt", 'a+')
				info_file.puts "Packet Information"
				info_file.puts "File sequence number: #{file_seq_num}"
				info_file.puts "Source Pi: #{source_pi}"
				info_file.puts "Staged time: #{staged_tai}"
				info_file.puts "Total number of packets: #{{total_packets}}"
				info_file.puts "MD5 Hash: #{file_md}"
				info_file.close


				#Add the packet data to file with the file sequence number associated
				data_file = File.open("C:/Users/STAR_User/Desktop/Image#{transfer_id}-Packet#{file_seq_num}.txt", 'a+') #open or create a text file with the same file path name as the downlinked file
				file.puts file_seq_num
				file.print data
				file.puts ""
				file.close

				return packet
			else
				return packet
			end
