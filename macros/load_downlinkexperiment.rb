# Loads the downlink experiment command sequence into the XB1 macro table (RAM).
# XB1 supports 96 macros IDs. BCT recommended using 60 and above for payload.
# Up to 400 commands can be stored in the macro table in total.
# See https://docs.google.com/spreadsheets/d/10WgwedfzKidc1ctJM_6SkyhKMu4D5LkdYQx-HkCGoqA/edit?usp=sharing 
# for current listing of custom macros. 

macro_id = 70
table_offset = 315
set_line_delay(0.1)

# Load switch: PAYLOAD_ENABLE OFF
time_offset_5Hz = 0
cmd("UUT STORE_MACRO_COMMAND with TABLE_SLOT #{table_offset}, MACRO_ID #{macro_id}, REL_TIME #{time_offset_5Hz}, LENGTH 4, RAW_BYTES [0x28,0x01,0x1B,0x00]")
table_offset += 1

# Load switch: V3_EN OFF
cmd("UUT STORE_MACRO_COMMAND with TABLE_SLOT #{table_offset}, MACRO_ID #{macro_id}, REL_TIME #{time_offset_5Hz}, LENGTH 4, RAW_BYTES [0x28,0x01,0x16,0x00]")
table_offset += 1

# Load switch: TIME_TONE OFF
cmd("UUT STORE_MACRO_COMMAND with TABLE_SLOT #{table_offset}, MACRO_ID #{macro_id}, REL_TIME #{time_offset_5Hz}, LENGTH 4, RAW_BYTES [0x28,0x01,0x1C,0x00]")
table_offset += 1

# Load switch: PAYLOAD_NOOP OFF
cmd("UUT STORE_MACRO_COMMAND with TABLE_SLOT #{table_offset}, MACRO_ID #{macro_id}, REL_TIME #{time_offset_5Hz}, LENGTH 4, RAW_BYTES [0x28,0x01,0x1D,0x00]")
table_offset += 1

# Wait 2 sec
time_offset_5Hz += 10

# Load switch: PAYLOAD ON
cmd("UUT STORE_MACRO_COMMAND with TABLE_SLOT #{table_offset}, MACRO_ID #{macro_id}, REL_TIME #{time_offset_5Hz}, LENGTH 4, RAW_BYTES [0x28,0x01,0x04,0x01]")
table_offset += 1

# Load switch: V3_EN ON
cmd("UUT STORE_MACRO_COMMAND with TABLE_SLOT #{table_offset}, MACRO_ID #{macro_id}, REL_TIME #{time_offset_5Hz}, LENGTH 4, RAW_BYTES [0x28,0x01,0x16,0x01]")
table_offset += 1

# Wait 1 sec
time_offset_5Hz += 5

# Load switch: PAYLOAD_ENABLE ON
cmd("UUT STORE_MACRO_COMMAND with TABLE_SLOT #{table_offset}, MACRO_ID #{macro_id}, REL_TIME #{time_offset_5Hz}, LENGTH 4, RAW_BYTES [0x28,0x01,0x1B,0x01]")
table_offset += 1

# Payload write 0x7EF: 1st VNC2 reprogramming init
cmd("UUT STORE_MACRO_COMMAND with TABLE_SLOT #{table_offset}, MACRO_ID #{macro_id}, REL_TIME #{time_offset_5Hz}, LENGTH 12, RAW_BYTES [0x0F,0x03,0x00,0x08,0x1F,0xEF,0xC0,0x00,0x00,0x01,0x2C,0xE7]")
table_offset += 1

# Wait 15 sec
time_offset_5Hz += 75

# Payload write 0x7EF: 2nd VNC2 reprogramming init
cmd("UUT STORE_MACRO_COMMAND with TABLE_SLOT #{table_offset}, MACRO_ID #{macro_id}, REL_TIME #{time_offset_5Hz}, LENGTH 12, RAW_BYTES [0x0F,0x03,0x00,0x08,0x1F,0xEF,0xC0,0x00,0x00,0x01,0x2C,0xE7]")
table_offset += 1

# Wait 5 sec
time_offset_5Hz += 25

# Load switch: TIME_TONE ON
cmd("UUT STORE_MACRO_COMMAND with TABLE_SLOT #{table_offset}, MACRO_ID #{macro_id}, REL_TIME #{time_offset_5Hz}, LENGTH 4, RAW_BYTES [0x28,0x01,0x1C,0x01]")
table_offset += 1

# Load switch: PAYLOAD_NOOP ON
cmd("UUT STORE_MACRO_COMMAND with TABLE_SLOT #{table_offset}, MACRO_ID #{macro_id}, REL_TIME #{time_offset_5Hz}, LENGTH 4, RAW_BYTES [0x28,0x01,0x1D,0x01]")
table_offset += 1
