#Test storing a macro execute command in a macro

#Execute Macro Command Definition
# COMMAND XACT MACRO_EXECUTE BIG_ENDIAN "Package Command; Executes a macro"
#   APPEND_ID_PARAMETER SYNC_HI 32 UINT 0xBC7DECAF 0xBC7DECAF 0xBC7DECAF "Sync Pattern (high)"
#     FORMAT_STRING "0x%08X"
#   APPEND_ID_PARAMETER SYNC_LO 32 UINT 0xDECAFBC7 0xDECAFBC7 0xDECAFBC7 "Sync Pattern (low)"
#     FORMAT_STRING "0x%08X"
#   APPEND_ID_PARAMETER LEN 32 UINT 6 6 6 "Length of Payload in Bytes"
#   APPEND_PARAMETER CCSDS_AP_ID 16 UINT 0x001 0x001 0x001 "CCSDS Ap Id"
#     STATE XB1 0x001
### END COSMOS Header
### BEGIN XB1 Command Data
#   APPEND_PARAMETER AP_ID 8 UINT 1 1 1 ""
#   APPEND_PARAMETER OP_CODE 8 UINT 7 7 7 ""
#   APPEND_PARAMETER MACRO_ID 16 UINT 1 65535 1 "ID of macro to which this command belongs.  MacroID must be less than the number of table slots."

#Define Macro ID and Table Offset 
macro_id = 95
table_offset = 395
set_line_delay(0.1)

#Define Execute Macro Command Raw Bytes (TODO: encapsulate this in a function)
data = []
data[0] = 1 #APID
data[1] = 7 #OP CODE
data[2] = 43 #Macro ID (for Payload On Macro)
packing = "C2S>" 
data_packed = data.pack(packing)
raw_bytes = data_packed.unpack("C*") #"Command as raw bytes, including ApId and OpCode"

# Load switch: PAYLOAD_ENABLE OFF
time_offset_5Hz = 0
cmd("UUT STORE_MACRO_COMMAND with TABLE_SLOT #{table_offset}, MACRO_ID #{macro_id}, REL_TIME #{time_offset_5Hz}, LENGTH #{raw_bytes.length}, RAW_BYTES #{raw_bytes}")
#puts raw_bytes