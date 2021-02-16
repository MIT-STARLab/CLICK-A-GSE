#CLICK Payload Command & Telemetry APIDs:
#Assumed path: C:\BCT\71sw0078_a_cosmos_click_edu\procedures\CLICK-A-GSE\lib\pl_cmd_tlm_apids.rb
#Reference: https://docs.google.com/spreadsheets/d/1ITNdvtceonKRpWd4pGuhg9Do2ZygTLGonbsYKwVzycM/edit#gid=1522568728

#Ground Command IDs
CMD_PL_REBOOT = 0x01
CMD_PL_SHUTDOWN = 0x02
CMD_PL_ENABLE_TIME = 0xC2
CMD_PL_EXEC_FILE = 0x67
CMD_PL_LIST_FILE = 0xFE
CMD_PL_AUTO_DOWNLINK_FILE = 0xAB
CMD_PL_DISASSEMBLE_FILE = 0x15
CMD_PL_REQUEST_FILE = 0x16
CMD_PL_UPLOAD_FILE = 0xCD
CMD_PL_ASSEMBLE_FILE = 0x39 
CMD_PL_VALIDATE_FILE = 0x40 
CMD_PL_MOVE_FILE = 0x41 
CMD_PL_DEL_FILE = 0x42 
CMD_PL_AUTO_ASSEMBLE_FILE = 0xCC
CMD_PL_SET_PAT_MODE = 0xB3
CMD_PL_SINGLE_CAPTURE = 0xF1
CMD_PL_CALIB_LASER_TEST = 0x4C 
CMD_PL_FSM_TEST = 0x28
CMD_PL_RUN_CALIBRATION = 0x32
CMD_PL_UPDATE_ACQUISITION_PARAMS = 0x86
CMD_PL_TX_ALIGN = 0x87 
CMD_PL_UPDATE_TX_OFFSETS = 0x88 
CMD_PL_UPDATE_FSM_ANGLES = 0x89 
CMD_PL_ENTER_PAT_MAIN = 0x90 
CMD_PL_EXIT_PAT_MAIN = 0x91 
CMD_PL_END_PAT_PROCESS = 0x92 
CMD_PL_SET_FPGA = 0x54
CMD_PL_GET_FPGA = 0x0E
CMD_PL_SET_HK = 0x97
CMD_PL_ECHO = 0x3D
CMD_PL_NOOP = 0x5B
CMD_PL_SELF_TEST = 0x80 
CMD_PL_UPDATE_SEED_PARAMS = 0x18
CMD_PL_DWNLINK_MODE = 0xE0 #Do not change - BCT
CMD_PL_DEBUG_MODE = 0xD0 #Do not change - BCT

#Telemetry APIDs
TLM_HK_SYS = 0x312 #TBR
TLM_HK_PAT = 0x313 #TBR
TLM_HK_FPGA_MAP = 0x314 #TBR
TLM_HK_CH = 0x315 #TBR
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
PAT_MODE_OPEN_LOOP_BUS_FEEDBACK = 0x04
PAT_MODE_BEACON_ALIGN = 0x0C

#define PAT self test flags
PAT_PASS_SELF_TEST = 0xFF
PAT_FAIL_SELF_TEST = 0x0F
PAT_NULL_SELF_TEST = 0x00

#Camera Params
CAMERA_WIDTH = 2592
CAMERA_HEIGHT = 1944
CAMERA_MAX_EXP = 10000000
CAMERA_MIN_EXP = 10

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

#HK FPGA Registers
ADDR_UNDER_128 = (0..4).to_a + (32..38).to_a + [47,48,53,54,57] + (60..63).to_a + (96..97).to_a
ADDR_200_300 = (200..205).to_a + (300..303).to_a
ADDR_EDFA = (602..611).to_a
NAMES_DAC_BLOCK = ['DAC_1_A', 'DAC_1_B', 'DAC_1_C', 'DAC_1_D', 'DAC_2_A', 'DAC_2_B', 'DAC_2_C', 'DAC_2_D']

#HK Sys Packet Fields
hk_sys_pkt_fixed_data_fields = %w[
    CCSDS_TAI_SECS
    HK_SYS_COUNTER
    ENABLE_FLAGS
    HK_FPGA_PERIOD
    HK_SYS_PERIOD
    CH_HEARTBEAT_PERIOD
    PAT_HEALTH_PERIOD
    ACK_CMD_COUNT
    LAST_ACK_CMD_ID
    ERROR_CMD_COUNT
    LAST_ERROR_CMD_ID
    BOOT_COUNT
    DISK_USED_MEMORY
    DISK_FREE_MEMORY
    AVAILABLE_VIRTUAL_MEMORY
]
hk_sys_pkt_fixed_data_fields_len = hk_sys_pkt_fixed_data_fields.length
HK_SYS_FIXED_DATA_LEN = 26
