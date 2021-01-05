load 'XB1/CLICK/crc16.rb'
set_line_delay(0.0)

# CCSDS constants
  IDX_CCSDS_VER = 0
  IDX_CCSDS_APID = 1
  IDX_CCSDS_GRP = 2
  IDX_CCSDS_SEQ = 3
  IDX_CCSDS_LEN = 4
  IDX_TIME_SEC = 5
  IDX_TIME_SUBSEC = 6
  IDX_RESERVED = 7

  CCSDS_VER = 0x18 # ver = 000b, type = 1b (cmd), sec hdr = 1b (yes)
  CCSDS_GRP_NONE = 0xC0 # grouping = 11b


def fmt_cmd(payload_apid, data)
  length = data.length
  pkt = []
   
  #puts "length of data: #{length} bytes"
  # construct a CCSDS Header
  head = []
  head[IDX_CCSDS_VER] = CCSDS_VER | (payload_apid >> 8)
  head[IDX_CCSDS_APID] = payload_apid & 0xFF
  head[IDX_CCSDS_GRP] = CCSDS_GRP_NONE
  head[IDX_CCSDS_SEQ] = 0
  head[IDX_CCSDS_LEN] = length - 1  + 2 # - 1 + 2 byte CRC 
  
  #puts "head: #{head}"

  # pack header the S> means format the short as big endian
  head = head.pack("C4S>") 
  
  d1 = data.pack("C*")
  crc1 = Crc16.new.update(d1.unpack("C*"))
  #puts "CRC of data only: #{crc1.to_s(16).upcase}"
  
  data = head + data.pack("C*")
  crc2 = Crc16.new.update(data.unpack("C*"))
  #puts "CRC of primary and secondary header and data: #{crc2.to_s(16).upcase}"
  
  if data.length > 0
    pkt = data 
    pkt += [Crc16.new.update(data.unpack("C*"))].pack("S>")
  end
  pkt = pkt.unpack("C*")
  cmd("UUT PAYLOAD_WRITE with RAW_BYTES #{pkt}, LENGTH #{pkt.length}")
end

#fmt_cmd(0x300,[5])