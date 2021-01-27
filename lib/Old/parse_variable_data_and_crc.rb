#Parse variable length data and crc for payload telemetry packet
#Assumed Path: #C:\BCT\71sw0078_a_cosmos_click_edu\procedures\lib\parse_variable_data_and_crc.rb

def parse_variable_data_and_crc(packet, packing)
    #Read the data bytes:
    pl_data_and_crc_bytes = packet.read('PL_VAR_DATA_AND_CRC')
    pl_data_and_crc_packed = pl_data_and_crc_bytes.pack("C*") #convert to packed string
    pl_data_and_crc_list = pl_data_and_crc_packed.unpack(packing) #unpack data to list
    pl_var_data = pl_data_and_crc_list[0] #get data from list
    crc = pl_data_and_crc_list[1] #get crc from list
    return pl_var_data, crc 
end