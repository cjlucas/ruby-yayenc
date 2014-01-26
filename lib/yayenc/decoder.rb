require 'pathname'
require 'stringio'
require 'zlib'

require 'yayenc/compat'
require 'yayenc/part'

module YAYEnc
  class Decoder

    def initialize(dest, options = {})
      @opts = {}
      @opts[:verify] = options.fetch(:verify, true)
      @opts[:warn] = options.fetch(:warn, false)
      @opts[:debug] = options.fetch(:debug, $DEBUG)

      @dirname = nil # used if dest is a directory
      @name = nil
      @expected_crc32 = 0
      @expected_size = 0
      @actual_size = 0
      # store the crc32 for each part to calculate the crc32 of the combined data
      # key: byte range value: pcrc32 integer value
      @pcrc32 = {}
      @done = false # flag set when all parts are processed
      @error_count = 0

      if dest.is_a?(String)
        @dirname = Pathname.new(dest)
        raise ArgumentError, 'Directory does not exist' unless @dirname.directory?
        raise ArgumentError, 'Directory is not writable' unless @dirname.writable?
      elsif dest.is_a?(StringIO)
        @dest_io = dest
      else
        raise ArgumentError, 'dest must be either String or IO'
      end
    end

    def name
      @name
    end

    def expected_size
      @expected_size
    end

    def file_path
      @dirname + @name unless @dirname.nil? || @name.nil?
    end

    def feed(data)
      part = Part.parse(data)
      self.name = part.name
      self.expected_size = part.total_size
      @expected_crc32 = part.crc32 unless part.crc32.zero?

      decoded_io = decode_part(part)

      # pos is zero-indexed
      dest_io.pos = part.start_byte - 1
      dest_io.write(decoded_io.read)
    end

    def dest_io
      return @dest_io unless @dest_io.nil?

      logd "will write decoded data to #{file_path}"
      @dest_io = File.open(file_path, 'wb')
    end

    def errors?
      @error_count > 0
    end

    def done?
      return true if @done

      sbr = sorted_byte_ranges
      return false if sbr[0].begin != 1 || sbr[-1].end != expected_size

      current_begin = 1
      sbr.each do |range|
        return false if range.begin != current_begin
        current_begin = range.end + 1
      end

      true
    end

    def crc32
      logw 'missing parts, crc32 will be incorrect' unless done?
      sbr = sorted_byte_ranges

      return 0 if sbr.empty?

      crc32 = 0
      sbr.each do |range|
        crc32 = Zlib.crc32_combine(crc32, @pcrc32[range], range.size)
      end

      crc32
    end

    private

    def name=(value)
      unless @name.nil? || @name.eql?(value)
        logw 'resetting name to a different name'
      end

      @name = value
    end

    def expected_size=(value)
      unless @expected_size.zero? || value == @expected_size
        logw 'changing expected_size'
      end

      @expected_size = value
    end

    def decode_part(part)
      sio = StringIO.new
      esc = false

      part.data.each_byte do |byte|
        next if [0x0A, 0x0D].include?(byte) # skip LF/CR
        esc = true and next if byte == 0x3D && !esc # skip if =

        sio.putc(decode_byte(byte, esc))
        esc = false
      end

      sio.rewind
      data = sio.read
      data_size = sio.size

      @actual_size += data_size
      pcrc32 = Zlib.crc32(data, 0)
      @pcrc32[part.byte_range] = pcrc32

      if @opts[:verify]
        unless part.pcrc32.zero? || pcrc32 == part.pcrc32
          @error_count += 1
          logw 'pcrc32 values do not match'
          logd "actual: #{pcrc32.to_s(16)}, expected: #{part.pcrc32.to_s(16)}"
        end

        unless data_size == part.part_size
          @error_count += 1
          logd "sio.size: #{sio.size}"
          logw 'part size does not match'
          logd "actual: #{data_size}, expected: #{part.part_size}"
        end
      end

      if @done = done? && @opts[:verify]
        logd "received all parts"
        crc32_value = crc32
        # can't assume part(s) contain crc32 value
        unless @expected_crc32.zero? || crc32_value == @expected_crc32
          @error_count += 1
          logw 'crc32 values do not match'
          logd "actual: #{crc32_value.to_s(16)}, expected: #{@expected_crc32.to_s(16)}"
        end

        unless @actual_size == @expected_size
          @error_count += 1
          logw 'total size does not match'
          logd "actual: #{@actual_size}, expected: #{@expected_size}"
        end
      end


      sio.rewind
      sio
    end

    def decode_byte(byte, esc)
      byte = (byte - 64) % 256 if esc
      byte = (byte - 42) % 256
    end

    def sorted_byte_ranges
      @pcrc32.keys.sort { |a, b| a.begin <=> b.begin }
    end

    def logw(str)
      $stderr.write("warning: #{str}\r\n") if @opts[:warn] || @opts[:debug]
    end

    def logd(str)
      $stderr.write("debug: #{str}\r\n") if @opts[:debug]
    end
  end
end
