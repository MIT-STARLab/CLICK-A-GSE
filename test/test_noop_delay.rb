load (Cosmos::USERPATH + '/procedures/CLICK-A-GSE/lib/click_cmd_tlm.rb')

# Change NOOP delay
cmd("UUT HOLDING_TABLE_INSERT with CCSDS_AP_ID XB1, WORD_OFFSET 0, WORD_LENGTH 1, RAW_BYTES [50, 0, 0, 0]")
cmd("UUT TABLE_COMMIT with CCSDS_AP_ID XB1, TABLE_NUM 15, WORD_OFFSET 59, WORD_LENGTH 1")
wait(0.1)

# Activate with any write command
click_cmd(CMD_PL_NOOP)

# Change SPI min delay
cmd("UUT HOLDING_TABLE_INSERT with CCSDS_AP_ID XB1, WORD_OFFSET 0, WORD_LENGTH 1, RAW_BYTES [50, 0, 0, 0]")
cmd("UUT TABLE_COMMIT with CCSDS_AP_ID XB1, TABLE_NUM 15, WORD_OFFSET 60, WORD_LENGTH 1")
wait(0.1)

# Activate with any write command
click_cmd(CMD_PL_NOOP)
