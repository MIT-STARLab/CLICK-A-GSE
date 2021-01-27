#Test Script - Echo
#Assumed Path: #C:\BCT\71sw0078_a_cosmos_click_edu\procedures\CLICK-A-GSE\test\test_echo.rb

load 'C:/BCT/71sw0078_a_cosmos_click_edu/procedures/CLICK-A-GSE/lib/click_cmd_tlm.rb'

#Subscribe to telemetry packets:
id = subscribe_packet_data([['UUT', 'PL_ECHO']], 1) #set queue depth to 1 (don't want history of all packets)

#echo data:
echo_data = 'TEST12'
#define data bytes:
data = []
data[0] = echo_data
packing = "a" + echo_data.length.to_s

#SM Send via UUT PAYLOAD_WRITE:
click_cmd(CMD_PL_ECHO, data, packing)

#Get telemetry packet:
packet = get_packet(id)
puts "PL_ECHO Packet Received: "

#Read the packet CCSDS primary header:
pl_ccsds_ver = packet.read('PL_CCSDS_VER')
pl_ccsds_type = packet.read('PL_CCSDS_TYPE')
pl_ccsds_secondary = packet.read('PL_CCSDS_SECNDRY')
pl_ccsds_apid = packet.read('PL_CCSDS_APID') #should be equal to TLM_ECHO
pl_ccsds_group = packet.read('PL_CCSDS_GRP')
pl_ccsds_sequence = packet.read('PL_CCSDS_SEQ')
pl_ccsds_length = packet.read('PL_CCSDS_LEN')

#Display CCSDS primary header:
puts "PL_CCSDS_VER: ", pl_ccsds_ver
puts "PL_CCSDS_TYPE: ", pl_ccsds_type
puts "PL_CCSDS_SECNDRY: ", pl_ccsds_secondary
puts "PL_CCSDS_APID = ", pl_ccsds_apid, "PL_CCSDS_APID == TLM_ECHO: ", (pl_ccsds_apid == TLM_ECHO)
puts "PL_CCSDS_GRP: ", pl_ccsds_group
puts "PL_CCSDS_SEQ: ", pl_ccsds_sequence
puts "PL_CCSDS_LEN: ", pl_ccsds_length

#Read the data bytes:
pl_data_and_crc_bytes = packet.read('PL_VAR_DATA_AND_CRC')
pl_data_and_crc_packed = pl_data_and_crc_bytes.pack("C*") #convert to packed string
echo_data_length = pl_ccsds_length - CRC_LEN + 1 #get data size
packing = "a" + echo_data_length.to_s + "S>" #define data packing for telemetry packet
pl_data_and_crc_list = pl_data_and_crc_packed.unpack(packing) #unpack data to list
echo_data_rx = pl_data_and_crc_list[0] #get data from list
crc_rx = pl_data_and_crc_list[1] #get crc from list

#Display echo data and check that echo worked:
puts "echo_data_rx: ", echo_data_rx, "echo_data_rx == echo_data: ", echo_data_rx == echo_data 

#Check the CRC:
packet_data_bytes = packet.buffer[26..(packet.buffer.length-CRC_LEN-1)] #get crc calculation argument: CCSDS header + data
crc_check = Crc16.new.update(packet_data_bytes.unpack("C*")) #check crc_rx
puts "crc_rx: ", crc_rx, "crc_rx == crc_check: ", (crc_rx == crc_check) #display crc and verify it

#Debug prints:
#puts "pl_data_and_crc_bytes: ", pl_data_and_crc_bytes
#puts "pl_data_and_crc_packed: ", pl_data_and_crc_packed
#puts "packing: ", packing
#puts "pl_data_and_crc_list: ", pl_data_and_crc_list
#puts "packet_data_bytes: ", packet_data_bytes