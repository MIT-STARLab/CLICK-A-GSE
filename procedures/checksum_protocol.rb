# encoding: ascii-8bit

# Copyright 2017 Ball Aerospace & Technologies Corp.
# All Rights Reserved.
#
# This program is free software; you can modify and/or redistribute it
# under the terms of the GNU General Public License
# as published by the Free Software Foundation; version 3 with
# attribution addendums as found in the LICENSE.txt

# Modified by Jenny Gubner from https://github.com/BallAerospace/COSMOS/blob/master/lib/cosmos/interfaces/protocols/crc_protocol.rb

require 'cosmos/config/config_parser'
require 'cosmos/interfaces/protocols/protocol'
#require 'cosmos/utilities/crc'
require 'thread'

module Cosmos
  # Creates a Checksum on write and verifies a Checksum on read
  class ChecksumProtocol < Protocol
    ERROR = "ERROR" # on Checksum mismatch
    DISCONNECT = "DISCONNECT" # on Checksum mismatch

    # @param write_item_name [String/nil] Item to fill with calculated Checksum value for outgoing packets (nil = don't fill)
    # @param strip_checksum [Boolean] Whether or not to remove the Checksum from incoming packets
    # @param bad_strategy [ERROR/DISCONNECT] How to handle Checksum errors on incoming packets.  ERROR = Just log the error, DISCONNECT = Disconnect interface
    # @param bit_offset [Integer] Bit offset of the Checksum in the data.  Can be negative to indicate distance from end of packet
    # @param bit_size [Integer] Bit size of the Checksum - Must be 16, 32, or 64
    # @param endianness [BIG_ENDIAN/LITTLE_ENDIAN] Endianness of the Checksum
    # @param poly [Integer] Polynomial to use when calculating the Checksum
    # @param seed [Integer] Seed value to start the calculation
    # @param xor [Boolean] Whether to XOR the Checksum result with 0xFFFF
    # @param reflect [Boolean] Whether to bit reverse each byte of data before calculating the Checksum
    # @param allow_empty_data [true/false/nil] See Protocol#initialize
    def initialize(
      write_item_name = CH_SUM,
      strip_checksum = false,
      bad_strategy = "ERROR",
      bit_offset = -16,
      bit_size = 16,
      endianness = 'BIG_ENDIAN',
      reflect = nil,
      allow_empty_data = nil
    )
      super(allow_empty_data)
      @write_item_name = ConfigParser.handle_nil(write_item_name)
      @strip_checksum = ConfigParser.handle_true_false(strip_checksum)
      raise "Invalid strip Checksum of '#{strip_checksum}'. Must be TRUE or FALSE." unless !!@strip_checksum == @strip_checksum

      case bad_strategy
      when ERROR, DISCONNECT
        @bad_strategy = bad_strategy
      else
        raise "Invalid bad Checksum strategy of #{bad_strategy}. Must be ERROR or DISCONNECT."
      end

      case endianness.to_s.upcase
      when 'BIG_ENDIAN'
        @endianness = :BIG_ENDIAN # Convert to symbol for use in BinaryAccessor.write
      when 'LITTLE_ENDIAN'
        @endianness = :LITTLE_ENDIAN # Convert to symbol for use in BinaryAccessor.write
      else
        raise "Invalid endianness '#{endianness}'. Must be BIG_ENDIAN or LITTLE_ENDIAN."
      end

      begin
        @bit_offset = Integer(bit_offset)
      rescue
        raise "Invalid bit offset of #{bit_offset}. Must be a number."
      end
      raise "Invalid bit offset of #{bit_offset}. Must be divisible by 8." if @bit_offset % 8 != 0


      # Build the Checksum arguments array. All subsequent arguments are dependent
      # on the previous ones so we build it up incrementally.
      args = []

      @bit_size = bit_size.to_i
      case @bit_size
      when 16
        @pack = (@endianness == :BIG_ENDIAN) ? 'n' : 'v'
        # if args.empty?
        #   @checksum = Checksum16.new
        # else
        #   @checksum = Checksum16.new(*args)
        # end
        raise "Invalid bit size of #{bit_size}. Must be 16."
      end
    end

    def checksum_calc(data)
      len = data.length
      data = data[0,len-3]
      checksum = 0xFFFF
      data.each_byte {|x| checksum += x }
      checksum &= 0xFFFF
      #data << [checksum].pack("n") # Pack as 16 bit unsigned bit endian
      #return data
      checksum = checksum.to_i
    end

    def read_data(data)
      return super(data) if (data.length <= 0)

      checksum = BinaryAccessor.read(@bit_offset, @bit_size, :UINT, data, @endianness)
      calculated_checksum = checksum_calc(data)
      if calculated_checksum != checksum
        Logger.error "Invalid Checksum detected! Calculated 0x#{calculated_checksum.to_s(16).upcase} vs found 0x#{checksum.to_s(16).upcase}."
        if @bad_strategy == DISCONNECT
          return :DISCONNECT
        end
      end
      if @strip_checksum
        new_data = data.dup
        new_data = new_data[0...(@bit_offset / 8)]
        end_range = (@bit_offset + @bit_size) / 8
        new_data << data[end_range..-1] if end_range != 0
        return new_data
      end
      return data
    end

    def write_packet(packet)
      if @write_item_name
        end_range = packet.get_item(@write_item_name).bit_offset / 8
        checksum = checksum_calc(packet.buffer)
        packet.write(@write_item_name, checksum)
      end
      packet
    end

    def write_data(data)
      unless @write_item_name
        if @bit_size == 64
          checksum = checksum_calc(data)
          data << ("\x00" * 8)
          BinaryAccessor.write((checksum >> 32), -64, 32, :UINT, data, @endianness, :ERROR)
          BinaryAccessor.write((checksum & 0xFFFFFFFF), -32, 32, :UINT, data, @endianness, :ERROR)
        else
          checksum = checksum_calc(data)
          data << ("\x00" * (@bit_size / 8))
          BinaryAccessor.write(checksum, -@bit_size, @bit_size, :UINT, data, @endianness, :ERROR)
        end
      end
      data
    end
  end
end