module YAYEnc
  class Part
    attr_accessor :line_width, :name, :pcrc32, :crc32
    attr_accessor :part_size, :total_size
    attr_accessor :part_num, :part_total
    attr_accessor :start_byte, :end_byte

    def initialize
      @lines = []
      @pcrc32 = 0
      @crc32 = 0
    end

    def <<(line)
      @lines << line
    end

    def data
      @lines.join("\n")
    end

    def final_part?
      part_num == part_total
    end
    
    def multi_part?
      part_total > 1
    end

    def to_s
      to_io.read
    end

    def to_io
      StringIO.new.tap do |sio|
        sio.write(ybegin << "\r\n")
        sio.write(ypart << "\r\n") if multi_part?
        sio.write(data << "\r\n")
        sio.write(yend << "\r\n")
        sio.rewind
      end
    end

    private

    def ybegin
      Array.new.tap do |head|
        head << '=ybegin'
        head << "part=#{part_num}" if multi_part?
        head << "total=#{total_size}"
        head << "line=#{line_width}"
        # "The filename must always be the last item on the header line."
        head << "name=#{name}" unless name.nil?
      end.join(' ')
    end

    def ypart
      Array.new.tap do |line|
        line << '=ypart'
        line << "begin=#{start_byte}"
        line << "end=#{end_byte}"
      end.join(' ')
    end

    def yend
      Array.new.tap do |line|
        line << '=yend'
        line << "size=#{part_size}" if multi_part?
        line << "part=#{part_num}" if multi_part?
        line << "pcrc32=#{pcrc32.to_s(16)}" unless pcrc32.zero? || !multi_part?
        line << "crc32=#{crc32.to_s(16)}" unless crc32.zero?
      end.join(' ')
    end
  end
end
