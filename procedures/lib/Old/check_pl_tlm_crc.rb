#Parse variable length data and crc for payload telemetry packet
#Assumed Path: #C:\BCT\71sw0078_a_cosmos_click_edu\procedures\lib\check_pl_tlm_crc.rb

load 'C:/BCT/71sw0078_a_cosmos_click_edu/procedures/lib/pl_cmd_tlm_apids.rb'
load 'C:/BCT/71sw0078_a_cosmos_click_edu/procedures/lib/crc16.rb'

def check_pl_tlm_crc(packet, crc_rx)
    #Check the CRC:
    packet_data_bytes = packet.buffer[COSMOS_HEADER_LENGTH..(packet.buffer.length-CRC_LEN-1)] #get crc calculation argument: CCSDS header + data
    crc_check = Crc16.new.update(packet_data_bytes.unpack("C*"))
    

end