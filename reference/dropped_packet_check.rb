# Script to see what packets were dropped in a file downlink
loop do
	file_list = Dir["C:/Users/STAR_User/Desktop/COSMOS_REV_C/37sw4455_c_cosmos_demi/outputs/data/*-information.rb"]

	packet_array = []
	File.foreach(file_list[0]) { |line| packet_array << line.to_i}
	rel_xfr = array[0]
	src_pi = array[1]
	rel_sd = array[2]
	tot_pack = array[3]
	new_array = packet_array[4..-1].uniq.sort

	j = 0
	while j <= tot_pack -1
		if new_array.include?(j) == false
        #puts "send command"
  		cmd("UUT ACK with TARGET_PI #{src_pi}, PI_REL #{src_pi}, SD_REL #{rel_sd}, TLM_SEQ_REL 0, TRANS_ID_REL #{rel_xfr}, FILE_SQ_REL #{j}, CS_STATUS BAD, RRX_REQ YES")
  	end
  	j+=1
	end

	if new_array.length ==tot_pack-1
		File.rename(file_list[0], "C:/Users/STAR_User/Desktop/COSMOS_REV_C/37sw4455_c_cosmos_demi/outputs/data/#{rel_xfr}-complete.rb")
		puts "All packets received for file #{rel_xfr}"
	end

	wait(10)

end