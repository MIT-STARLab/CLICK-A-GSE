# Script to see what packets were dropped in a file downlink
require 'OpenSSL'
loop do
  # Generate an array list of the -information files generated in the outputs/data folder
	file_list = Dir["C:/Users/STAR_User/Desktop/COSMOS_REV_C/37sw4455_c_cosmos_demi/outputs/data/*-information.txt"]
    if file_list.length == 0
      puts "No available files"
      wait(10)
    else
      packet_array = []
      File.foreach(file_list[0]) { |line| packet_array << line.to_i} #Selects the first file in the list and adds the packet sequence numbers to an array
      rel_xfr = packet_array[0]
      src_pi = packet_array[1]
      rel_sd = packet_array[2]
      tot_pack = packet_array[3]
      new_array = packet_array[4..-1].uniq.sort # Gets rid of repitions in the packet sequence array and sorts it in ascending order
          
      j = 0
      while j <= tot_pack -1
        if new_array.include?(j) == false #if the array does not have a packet sequence number
          #puts "send nack command"
          cmd("UUT ACK with TARGET_PI #{src_pi}, PI_REL #{src_pi}, SD_REL #{rel_sd}, TLM_SEQ_REL 0, TRANS_ID_REL #{rel_xfr}, FILE_SQ_REL #{j}, CS_STATUS BAD, RRX_REQ YES")
          wait(1)
        end
        j+=1
      end
      wait(1)
      # If the new array length matches the number of expected packets, reneame the information file to a -complete file
      # I will eventually add in a parse and generate the actual file from the data file
      if new_array.length == tot_pack
        File.rename(file_list[0], "C:/Users/STAR_User/Desktop/COSMOS_REV_C/37sw4455_c_cosmos_demi/outputs/data/#{rel_xfr}-complete.txt")
        
        # input the filename you want to chunk together: 
        filename = "#{rel_xfr}.fits"
        reconstructed_filename = "C:/Users/STAR_User/Desktop/COSMOS_REV_C/37sw4455_c_cosmos_demi/outputs/data/chunks/reconstructed_"+filename
        puts reconstructed_filename

        # input the chunk names according to naming convention from downlink: 
        chunk_name = filename.split(".")[0]
        puts chunk_name
        
        ## retrieve how many chunks we have in chunks folder to put back together:
        filelist =  Dir["C:/Users/STAR_User/Desktop/COSMOS_REV_C/37sw4455_c_cosmos_demi/outputs/data/#{chunk_name}*.chk"]
        num_chunks = filelist.length
        puts "file list #{filelist}"
        puts "num chunks #{num_chunks}"

        ## put file back together based on chunks in chunks folder: 
        i=0
        File.open(reconstructed_filename, 'wb') {|f| 
          while i<num_chunks do
            chunk_filename = "C:/Users/STAR_User/Desktop/COSMOS_REV_C/37sw4455_c_cosmos_demi/outputs/data/" + chunk_name + "-" + i.to_s + ".chk"
            file = File.open("#{chunk_filename}", "rb")
            chunk_contents = file.read.bytes
            #print file_contents
            chunk_length = chunk_contents.length
            print("chunk contents length: #{chunk_length}\n")
            f.write(chunk_contents.pack('C*'))
            i+=1
          end 
        }


        ## compare hash of file to the hash that got downlinked with packets: 

        data = File.read(reconstructed_filename)
        MD5 = OpenSSL::Digest::MD5.new
        digest = MD5.hexdigest data

        puts "hash: #{digest}"


        puts "All packets received for file #{rel_xfr}"
      end
    end
    wait(1)
end