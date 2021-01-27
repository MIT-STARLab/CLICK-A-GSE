buffer = get_cmd_buffer("UUT","PL_REBOOT")
pkt = buffer.unpack('C*')
puts pkt[14..(pkt.length()-3)]
