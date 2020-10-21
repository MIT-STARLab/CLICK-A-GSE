# sending first commands
load 'XB1/CLICK/fmt_cmd_click.rb'

set_line_delay(0.5)

#  fmt_cmd(0x201... - will send a command over the UART
#  fmt_cmd(0x300+ will send a command over the SPI

def uart_cmd_loop
wait 1
#loop = 1000
loop = 10
cmd_accept_cnt = tlm("UUT COMMAND_TLM REALTIME_CMD_ACCEPT_COUNT") 
puts cmd_accept_cnt
loop.times do |i|
   fmt_cmd(0x201,[0xaa,0,0,0,0xbb,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0])
   wait 1
end
end

def spi_pyld_ctrl_pkt(raw_bytes = 0x47)
    loop = 2
    cmd_accept_cnt = tlm("UUT COMMAND_TLM REALTIME_CMD_ACCEPT_COUNT") 
    #puts cmd_accept_cnt
    loop.times do |i|
       fmt_cmd(0x250, [0x33, raw_bytes]) #Payload Control Packet       
       wait 1
    end
    wait_check("UUT COMMAND_TLM REALTIME_CMD_ACCEPT_COUNT == #{(cmd_accept_cnt + loop) % 256}", 10)
    #puts "#{cmd_accept_cnt + loop}"
end

def spi_request(apid = 0x301)
    loop = 2
    cmd_accept_cnt = tlm("UUT COMMAND_TLM REALTIME_CMD_ACCEPT_COUNT") 
    #puts cmd_accept_cnt
    loop.times do |i|
       fmt_cmd(apid,[0x33, (apid & 0xFF)]) #Request Packet Command      
       wait 1
    end
    wait_check("UUT COMMAND_TLM REALTIME_CMD_ACCEPT_COUNT == #{(cmd_accept_cnt + loop) % 256}", 10)
    #puts "#{cmd_accept_cnt + loop}"
end

def spi_request_cycle
    loop = 1
    cmd_accept_cnt = tlm("UUT COMMAND_TLM REALTIME_CMD_ACCEPT_COUNT") 
    #puts cmd_accept_cnt
    loop.times do |i|
      fmt_cmd(0x1ff,[0x11])
      wait 1
    end
    wait_check("UUT COMMAND_TLM REALTIME_CMD_ACCEPT_COUNT == #{(cmd_accept_cnt + loop) % 256}", 10)
    #puts "#{cmd_accept_cnt + loop}"
end

def spi_loop_250(data)
   buf = Array.new
   buf = data.pack("g3").unpack("C*") 
   #puts "buf: #{buf}"
   fmt_cmd(0x250,buf)
end

#also enable the payload
cmd("UUT SET_LOAD_SWITCH with CCSDS_AP_ID XB1, SWITCH_NUM IO22_V3_EN, STATUS ON")
cmd("UUT SET_LOAD_SWITCH with CCSDS_AP_ID XB1, SWITCH_NUM IO4_PAYLOAD, STATUS ON")
wait 2
cmd("UUT SET_LOAD_SWITCH with CCSDS_AP_ID XB1, SWITCH_NUM IO27_PAYLOAD_ENABLE, STATUS ON")

wait

spi_request(0x301)
#uart_cmd_loop()
#spi_pyld_ctrl_pkt(0x46)
#spi_request_cycle()

# 0x3dcccccd = 0.1  0x3f000000 = 0.5  0xbf800000 = -1.0
#fmt_cmd(0x250,[0x3d,0xcc,0xcc,0xcd,0x3f,0,0,0,0xbf,0x80,0,0])y\

#spi_loop_250([-0.001, -0.001,0.001])


loop = 20
loop.times do |i|
#spi_loop_250([-0.1, 0.01,0.001])
end