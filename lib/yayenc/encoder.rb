require 'stringio'
require 'zlib'

module YAYEnc

  class InvalidInputException < Exception; end;

  class Encoder
    SPECIAL_BYTES = [0x00, 0x0A, 0x0D, 0x3D]
    DEFAULT_PART_SIZE = 500_000 - 1
    LINE_WIDTH = 128

    def self.encode(src, **opts, &block)
      new(src, **opts).encode(&block)
    end

    def initialize(src, **opts)
      @opts = {}

      if src.is_a?(String)
        @src_io = File.open(src, 'rb')
      elsif src.is_a?(IO)
        @src_io = src
      else
        raise InvalidInputException 'src must be an IO object or a path to a file'
      end

      @src_io.rewind

      @opts[:multi_part] = opts.fetch(:multi_part, false)
      if @opts[:multi_part]
        @opts[:part_size] ||= DEFAULT_PART_SIZE
      else
        @opts[:part_size] = @src_io.size
      end
    end

    def encode(&block)
      parts = []
      total_parts = (@src_io.size / @opts[:part_size]).ceil
      cur_part_num = 1
      start_byte = 1

      until @src_io.eof?
        part = encode_part(@src_io.read(@opts[:part_size]))
        part.part_num = cur_part_num
        part.part_total = total_parts
        part.start_byte = start_byte
        part.end_byte = start_byte + part.size

        block_given? ? block.call(part) : parts << part

        cur_part_num += 1
        start_byte = part.end_byte + 1
      end
      @src_io.close

      parts unless block_given?
    end

    private

    def encode_part(data)
      part = Part.new
      part.line_width = LINE_WIDTH
      part.size = data.size

      StringIO.open(data) do |data_io|
        until data_io.eof?
          line_data = data_io.read(LINE_WIDTH)
          part.pcrc32 = Zlib.crc32(line_data, part.pcrc32)
          part << encode_line(line_data).read
        end
      end

      part
    end

    def encode_line(data)
      enc_io = StringIO.new

      data.each_byte do |byte|
        byte = (byte + 42) % 256
        if SPECIAL_BYTES.include?(byte)
          enc_io.putc 0x3D
          byte = (byte + 64) % 256
        end

        enc_io.putc byte
      end

      enc_io.rewind
      enc_io
    end

  end
end
