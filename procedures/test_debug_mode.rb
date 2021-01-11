#Test Script - PL_CONFIG_OPTICAL_DOWNLINK

ap_id = 15
ap_id_type = "C"
op_code = 3
op_code_type = "C"
cmd_length = 3
cmd_length_type = "S>"
rpi_apid = 0xD0
rpi_apid_type = "C"

xb1_cmd_data = []
packing_directives = ""
xb1_cmd_data[0] = ap_id
packing_directives += ap_id_type
xb1_cmd_data[1] = op_code
packing_directives += op_code_type
xb1_cmd_data[2] = cmd_length
packing_directives += cmd_length_type
xb1_cmd_data[3] = rpi_apid
packing_directives += rpi_apid_type

xb1_cmd_data_packed = xb1_cmd_data.pack(packing_directives)
xb1_cmd_data_unpacked = xb1_cmd_data_packed.unpack("C*")
ch_sum = Crc16.new.update(xb1_cmd_data_unpacked)

puts xb1_cmd_data
puts packing_directives
puts xb1_cmd_data_packed
puts xb1_cmd_data_unpacked
puts ch_sum

cmd("UUT PL_CONFIG_DEBUG with CH_SUM #{ch_sum}")
buffer = get_cmd_buffer("UUT","PL_CONFIG_DEBUG")
cmd_pkt = buffer.unpack("C*")
puts cmd_pkt[14..cmd_pkt.length()]