module YAYEnc
  class Part
    attr_accessor :line_width, :name, :pcrc32, :crc32
    attr_accessor :part_size, :total_size
    attr_accessor :part_num, :part_total
    attr_accessor :start_byte, :end_byte

    def self.parse(input)
      part = Part.new
      in_data = false

      input.each_line do |line|
        next unless in_data || line =~ /^=ybegin\s/i
        # an "invalid byte sequence" exception will be thrown if
        # a regexp check is used on a yEnc data line, so use substring
        part << line and next unless line[0, 2].eql?("=y")

        self.parse_line(part, line)
        in_data = true

        break if line =~ /^=yend/i
      end

      unless part.multi_part?
        part.start_byte = 1
        part.end_byte = part.total_size
      end

      part
    end

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
        head << "total=#{part_total}"
        head << "line=#{line_width}"
        head << "size=#{total_size}"
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

    def self.parse_line(part, line)
      case line
      when /^=ybegin/i
        parse_ybegin(part, line)
      when /^=ypart/i
        parse_ypart(part, line)
      when /^=yend/i
        parse_yend(part, line)
      end
    end

    def self.parse_ybegin(part, line)
      line.chomp! # strip newline chars

      m = /\sline\=(\d*)/.match(line)
      part.line_width = m[1].to_i unless m.nil?

      m = /\spart\=(\d*)/.match(line)
      part.part_num = m[1].to_i unless m.nil?

      m = /\stotal\=(\d*)/.match(line)
      part.part_total = m[1].to_i unless m.nil?

      m = /\ssize\=(\d*)/.match(line)
      part.total_size = m[1].to_i unless m.nil?

      m = /\sname\=(.*)$/.match(line)
      part.name = m[1] unless m.nil?
    end

    def self.parse_ypart(part, line)
      line.chomp! # strip newline chars

      m = /\sbegin\=(\d*)/.match(line)
      part.start_byte = m[1].to_i unless m.nil?

      m = /\send\=(\d*)/.match(line)
      part.end_byte = m[1].to_i unless m.nil?
    end

    def self.parse_yend(part, line)
      line.chomp! # strip newline chars

      m = /\ssize\=(\d*)/.match(line)
      part.part_size = m[1].to_i unless m.nil?

      m = /\spart\=(\d*)/.match(line)
      part.part_num = m[1].to_i unless m.nil?

      m = /\spcrc32\=(\w*)/.match(line)
      part.pcrc32 = m[1].to_i(16) unless m.nil?

      m = /\scrc32\=(\w*)/.match(line)
      part.crc32 = m[1].to_i(16) unless m.nil?
    end
  end
end
