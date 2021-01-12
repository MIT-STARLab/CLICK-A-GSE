#Definition of generic CLICK payload command format for COSMOS
#Includes CCSDS header definitions, CRC calculation, and sending via BCT PAYLOAD_WRITE command.
#Assumed Path: #C:\BCT\71sw0078_a_cosmos_click_edu\procedures\click_cmd.rb

load 'crc16.rb'

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

SECONDARY_HEADER_LEN = 5
CRC_LEN = 2

def click_cmd(cmd_id, data = [], packing = "C*")
    #cmd_ids defined here: https://docs.google.com/spreadsheets/d/1ITNdvtceonKRpWd4pGuhg9Do2ZygTLGonbsYKwVzycM/edit#gid=1522568728
    #data_packed is a packed data set (e.g. [0x01,0x0200].pack("CS>")): https://www.rubydoc.info/stdlib/core/1.9.3/Array:pack 
    
    #pack data into binary sequence
    data_packed = data.pack(packing) 

    #get packet length (secondary header + data bytes + crc - 1)
    packet_length = data_packed.length + SECONDARY_HEADER_LEN + CRC_LEN - 1

    #get time stamp
    utc_time = Time.now.utc.to_f
    utc_time_sec = utc_time.floor #uint32
    utc_time_subsec = (5*(utc_time - utc_time_sec)).round #= ((1000*frac)/200).round

    #construct CCSDS header (primary and secondary)
    header = []
    header[IDX_CCSDS_VER] = CCSDS_VER | (cmd_id >> 8)
    header[IDX_CCSDS_APID] = cmd_id & 0xFF
    header[IDX_CCSDS_GRP] = CCSDS_GRP_NONE
    header[IDX_CCSDS_SEQ] = 0
    header[IDX_CCSDS_LEN] = packet_length 
    header[IDX_TIME_SEC] = utc_time_sec
    header[IDX_TIME_SUBSEC] = utc_time_subsec
    header[IDX_RESERVED] = 0
    packing_header = "C4S>L>C2"   
    header_packed = header.pack(packing_header) 

    #compute CRC16 and append to packet
    packet_packed = header_packed + data_packed
    crc = Crc16.new.update(packet_packed.unpack("C*"))
    packet_packed += [crc].pack("S>")
  
    #send PAYLOAD_WRITE command
    raw_bytes = packet_packed.unpack("C*")
    cmd("UUT PAYLOAD_WRITE with RAW_BYTES #{raw_bytes}, LENGTH #{raw_bytes.length}")
end