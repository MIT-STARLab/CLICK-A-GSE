#Test Script - Reprogramming
#Assumed Path: C:\CLICK-A-GSE\test\test_reprogramming.rb

load ('C:/CLICK-A-GSE/test/payload_cmd.rb')
set_line_delay(0.0)

# Make sure payload is powered off
cmd("UUT SET_LOAD_SWITCH with SWITCH_NUM 27, STATUS 0")
cmd("UUT SET_LOAD_SWITCH with SWITCH_NUM 22, STATUS 0")

# Disable time of tone and noop packets
cmd("UUT SET_LOAD_SWITCH with SWITCH_NUM 28, STATUS 0")
cmd("UUT SET_LOAD_SWITCH with SWITCH_NUM 29, STATUS 0")

# Turn payload power on, keep Pi reset active
wait(2)
cmd("UUT SET_LOAD_SWITCH with SWITCH_NUM 4, STATUS 1")
cmd("UUT SET_LOAD_SWITCH with SWITCH_NUM 22, STATUS 1")

# Short wait for VNC2 boot
wait(1)

# Release Pi reset
cmd("UUT SET_LOAD_SWITCH with SWITCH_NUM 27, STATUS 1")

# Send empty reprogramming init SPI command to VNC2
PayloadCmd.new.send(0x7EF, [])

# Wait for VNC2 to complete reset sequence into usb bootloader mode
wait(15)

# Send second reprogramming init command to VNC2
PayloadCmd.new.send(0x7EF, [])

# Wait for VNC2 to transmit the embedded first stage bootloader
wait(5)

# Re-enable time of tone and noop packets
cmd("UUT SET_LOAD_SWITCH with SWITCH_NUM 28, STATUS 1")
cmd("UUT SET_LOAD_SWITCH with SWITCH_NUM 29, STATUS 1")

# Start golden image transmission
cmd("UUT PYLD_CFDP_DL_FILE with PKT_LEN 62, CCSDS_AP_ID 496, TRN_ID 17, SRC_PATH /mnt/sd/general/click_golden.img")
