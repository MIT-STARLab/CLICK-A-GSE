#CLICK Payload Command & Telemetry APIDs:
#Assumed path: C:\BCT\71sw0078_a_cosmos_click_edu\procedures\CLICK-A-GSE\lib\pl_cmd_tlm_apids.rb
#Reference: https://docs.google.com/spreadsheets/d/1ITNdvtceonKRpWd4pGuhg9Do2ZygTLGonbsYKwVzycM/edit#gid=1522568728

#Ground Command IDs
CMD_PL_REBOOT = 0x01
CMD_PL_ENABLE_TIME = 0xC2
CMD_PL_DISABLE_TIME = 0xA4
CMD_PL_EXEC_FILE = 0x67
CMD_PL_LIST_FILE = 0xFE
CMD_PL_REQUEST_FILE = 0xAB
CMD_PL_UPLOAD_FILE = 0xCD
CMD_PL_ASSEMBLE_FILE = 0x39 #Change
CMD_PL_VALIDATE_FILE = 0x40 
CMD_PL_MOVE_FILE = 0x41 #Change
CMD_PL_DEL_FILE = 0x42 #Change
CMD_PL_SET_PAT_MODE = 0xB3
CMD_PL_SINGLE_CAPTURE = 0xF1
CMD_PL_CALIB_LASER_TEST = 0x4C 
CMD_PL_FSM_TEST = 0x28
CMD_PL_RUN_CALIBRATION = 0x32
CMD_PL_PAT_TEST = 0x90 #Change
#TODO: More PAT cmds - add TX_ALIGN, Tx Offset Updates, FSM Updates
CMD_PL_END_PAT_PROCESS = 0x91 #Change
CMD_PL_RESTART_PAT_PROCESS = 0x92 #Change
CMD_PL_SET_FPGA = 0x54
CMD_PL_GET_FPGA = 0x0E
CMD_PL_SET_HK = 0x97
CMD_PL_ECHO = 0x3D
CMD_PL_NOOP = 0x5B
CMD_PL_SELF_TEST = 0x80 #Change
CMD_PL_DWNLINK_MODE = 0xE0 #Do not change - BCT
CMD_PL_DEBUG_MODE = 0xD0 #Do not change - BCT

#Telemetry APIDs
TLM_HK_SYS = 0x312 #TBR
TLM_HK_PAT = 0x313 #TBR
TLM_HK_FPGA_MAP = 0x314 #TBR
TLM_DL_FILE = 0x387 #TBR
TLM_LIST_FILE = 0x3E0 
TLM_ASSEMBLE_FILE = 0x3B0 #TBR
TLM_GET_FPGA = 0x3C0
TLM_ECHO = 0x3FF 
TLM_GENERAL_SELF_TEST = 0x3D0
TLM_LASER_SELF_TEST = 0x3D1
TLM_PAT_SELF_TEST = 0x3D2

#Self Test IDs
GENERAL_SELF_TEST = 0x00
LASER_SELF_TEST = 0x01
PAT_SELF_TEST = 0x02

#define PAT Mode IDs
PAT_MODE_DEFAULT = 0x00
PAT_MODE_OPEN_LOOP = 0x01
PAT_MODE_STATIC_POINTING = 0x02
PAT_MODE_BUS_FEEDBACK = 0x03
PAT_MODE_BEACON_ALIGN = 0x0C

#define PAT self test flags
PAT_PASS_SELF_TEST = 0xFF
PAT_FAIL_SELF_TEST = 0x0F
PAT_NULL_SELF_TEST = 0x00

# CCSDS constants for command packets
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
SECONDARY_HEADER_LEN = 6
CRC_LEN = 2

#COSMOS header length for telemetry packets
COSMOS_HEADER_LENGTH = 26 

# File Handling Options Settings
FL_ERR_EMPTY_DIR = 0x01
FL_ERR_FILE_NAME = 0x02
FL_ERR_SEQ_LEN = 0x03
FL_ERR_MISSING_CHUNK = 0x04
FL_SUCCESS = 0xFF
