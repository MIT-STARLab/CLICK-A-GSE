# Loads the downlink experiment command sequence into the XB1 macro table (RAM).
# XB1 supports 96 macros IDs. BCT recommended using 60 and above for payload.
# Up to 400 commands can be stored in the macro table in total.
# See https://docs.google.com/spreadsheets/d/10WgwedfzKidc1ctJM_6SkyhKMu4D5LkdYQx-HkCGoqA/edit?usp=sharing 
# for current listing of custom macros. 

def store_macro_execute(time_offset_5Hz, submacro_id, table_offset, macro_id)
    #Define Execute Macro Command Raw Bytes
    data = []
    data[0] = 1 #APID
    data[1] = 7 #OP CODE
    data[2] = submacro_id #Macro ID (for Payload On Macro)
    packing = "C2S>" 
    data_packed = data.pack(packing)
    raw_bytes = data_packed.unpack("C*") #"Command as raw bytes, including ApId and OpCode"

    #Store Execute Macro Command in Macro Table
    cmd("UUT STORE_MACRO_COMMAND with TABLE_SLOT #{table_offset}, MACRO_ID #{macro_id}, REL_TIME #{time_offset_5Hz}, LENGTH #{raw_bytes.length}, RAW_BYTES #{raw_bytes}")
end

def store_macro_execute_sequence(macro_id, start_table_offset, time_offsets_5Hz, submacro_sequence)
    table_offset = start_table_offset
    for i in 0..(time_offsets_5Hz.length - 1)
        store_macro_execute(time_offsets_5Hz[i], submacro_sequence[i], table_offset, macro_id)
        table_offset += 1
    end
end

set_line_delay(0.1)
SEC2CYCLES = 5

#Define Macro ID and Starting Table Offset for Downlink Experiment Macro
MACRO_ID_TEST = 90
START_TABLE_OFFSET_TEST = 390

#Define Macro IDs for Sub-Macros:
#T = 0: Execute Macro 43 - Payload On. Runs for 37 sec up to T = 37 sec.
#T = 1 min = 60 sec: Execute Macro 30 - Payload Off. Runs for 2 sec up to T = 62 sec.

MACRO_ID_PAYLOAD_ON = 43
MACRO_ID_PAYLOAD_OFF = 30
time_offsets_5Hz = [0, 60*SEC2CYCLES] #Define Execution Times for Sub-Macros
submacro_sequence = [MACRO_ID_PAYLOAD_ON, MACRO_ID_PAYLOAD_OFF] #Define Sub-Macro Sequence

store_macro_execute_sequence(MACRO_ID_TEST, START_TABLE_OFFSET_TEST, time_offsets_5Hz, submacro_sequence)
