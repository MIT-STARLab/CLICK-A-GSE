#Test Script - Echo
#Assumed Path: #C:\BCT\71sw0078_a_cosmos_click_edu\procedures\test_echo.rb

load 'C:/BCT/71sw0078_a_cosmos_click_edu/procedures/lib/pl_cmd_tlm_apids.rb'
load 'C:/BCT/71sw0078_a_cosmos_click_edu/procedures/lib/click_cmd.rb'

#Subscribe to telemetry packets
id = subscribe_packet_data([['UUT', 'PL_ECHO']], 1000) #set queue depth to 1000

#echo data
echo_data = 'HelloWorld'
#define data bytes
data = []
data[0] = echo_data
packing = "a" + echo_data.length.to_s

#SM Send via UUT PAYLOAD_WRITE
click_cmd(CMD_PL_ECHO, data, packing)

#Get response
packet = get_packet(id)
puts "PL_ECHO Packet Received: "
# Read the packet CCSDS primary header:
pl_ccsds_ver = packet.read('PL_CCSDS_VER')
pl_ccsds_type = packet.read('PL_CCSDS_TYPE')
pl_ccsds_secondary = packet.read('PL_CCSDS_SECNDRY')
pl_ccsds_apid = packet.read('PL_CCSDS_APID') #should be equal to TLM_ECHO
pl_ccsds_group = packet.read('PL_CCSDS_GRP')
pl_ccsds_sequence = packet.read('PL_CCSDS_SEQ')
pl_ccsds_length = packet.read('PL_CCSDS_LEN')
puts "PL_CCSDS_VER: ", pl_ccsds_ver
puts "PL_CCSDS_TYPE: ", pl_ccsds_type
puts "PL_CCSDS_SECNDRY: ", pl_ccsds_secondary
puts "PL_CCSDS_APID = ", pl_ccsds_apid, ". PL_CCSDS_APID == TLM_ECHO: ", (pl_ccsds_apid == TLM_ECHO)
puts "PL_CCSDS_GRP: ", pl_ccsds_group
puts "PL_CCSDS_SEQ: ", pl_ccsds_sequence
puts "PL_CCSDS_LEN: ", pl_ccsds_length

#Read the data bytes:
pl_data_and_crc_bytes = packet.read('PL_DATA_AND_CRC')
#convert to packed string
pl_data_and_crc_packed = pl_data_and_crc.pack("C*")

#define the telemetry packing
echo_data_length = pl_ccsds_length - CRC_LEN + 1
packing = "a" + echo_data_length.to_s + "S>"

#unpack data to list and display
pl_data_and_crc_list = pl_data_and_crc_packed.unpack(packing)
echo_data = pl_data_and_crc_list[0]
crc_rx = pl_data_and_crc_list[1]
puts "echo_data: ", echo_data

#check crc_rx
packet_data_bytes = packet[0..(packet.length-2)]
puts "packet_data_bytes: ", packet_data_bytes
crc_check = Crc16.new.update(packet_data_bytes.unpack("C*"))
puts "crc_rx: ", crc_rx, ". crc_rx == crc_check: ", (crc_rx == crc_check)