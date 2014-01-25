require 'stringio'
require 'zlib'

require 'yayenc/part'

module YAYEnc
  class Decoder
    def initialize(dest)
      if dest.is_a?(String)
        raise ArgumentError, 'If dest is a String, it must be a directory path' unless Dir.exists?(dest)

        @dest = Pathname.new(dest)
      elsif dest.is_a?(StringIO)
        @dest_io = dest
      else
        raise ArgumentError, 'dest must be either String or IO'
      end

      @opts = {}
      @opts[:warn] = true
      @opts[:verify] = true
    end

    def feed(data)
      part = Part.parse(data)
      decoded_io = decode_part(part)

      # pos is zero-indexed
      dest_io.pos = part.start_byte - 1
      dest_io.write(decoded_io.read)
    end

    def dest_io
      return @dest_io unless @dest_io.nil?

    end

    private

    def decode_part(part)
      sio = StringIO.new
      esc = false

      part.data.each_byte do |byte|
        next if byte == 0x0A || byte == 0x0D # skip LF/CR
        esc = true and next if byte == 0x3D && !esc # skip if =

        sio.putc(decode_byte(byte, esc))
        esc = false
      end

      sio.rewind
      sio
    end

    def decode_byte(byte, esc)
      byte = (byte - 64) % 256 if esc
      byte = (byte - 42) % 256
    end

    private

    def warn(str)
      $stderr.write(str << "\r\n") if @opts[:warn]
    end
  end
end
