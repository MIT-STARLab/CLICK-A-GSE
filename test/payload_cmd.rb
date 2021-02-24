#Deprecated Payload Command - Used by test_reprogramming.rb (see click_cmd_tlm.rb for up-to-date click_cmd function)
#Assumed Path: C:\CLICK-A-GSE\test\payload_cmd.rb

load ('C:/CLICK-A-GSE/lib/crc16.rb')

class PayloadCmd

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


  def send(payload_apid, data)
    length = data.length
    pkt = []
    
    # construct a CCSDS Header
    head = []
    head[IDX_CCSDS_VER] = CCSDS_VER | (payload_apid >> 8)
    head[IDX_CCSDS_APID] = payload_apid & 0xFF
    head[IDX_CCSDS_GRP] = CCSDS_GRP_NONE
    head[IDX_CCSDS_SEQ] = 0
    head[IDX_CCSDS_LEN] = length - 1  + 2 # - 1 + 2 byte CRC 
    
    # pack header the S> means format the short as big endian
    data = head.pack("C4S>") + data.pack("C*")
    
    # add CRC
    if data.length > 0
      pkt = data 
      pkt += [Crc16.new.update(data.unpack("C*"))].pack("S>")
    end

    pkt = pkt.unpack("C*")
    cmd("UUT PAYLOAD_WRITE with RAW_BYTES #{pkt}, LENGTH #{pkt.length}")
  end
  
end