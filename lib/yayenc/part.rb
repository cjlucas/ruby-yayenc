require 'stringio'

module YAYEnc
  class Part
    attr_accessor :line_width, :name, :pcrc32, :crc32
    attr_accessor :part_size, :total_size
    attr_accessor :part_num, :part_total
    attr_accessor :start_byte, :end_byte
    attr_accessor :multi_part

    def self.parse(input)
      part = Part.new
      in_data = false

      input.each_line do |line|
        next unless in_data || line =~ /^=ybegin\s/i
        # an "invalid byte sequence" exception will be thrown if
        # a regexp check is used on a yEnc data line, so use substring
        part << line.bytes and next unless line[0, 2].eql?("=y")

        part.multi_part = true if line =~ /^=ypart\s/i

        self.parse_line(part, line)
        in_data = true

        break if line =~ /^=yend/i
      end

      # required for decoding
      unless part.multi_part?
        part.start_byte ||= 1
        part.end_byte ||= part.total_size
      end

      part
    end

    def initialize
      @data = [] # bytes
      @pcrc32 = 0
      @crc32 = 0
      @part_num = 1
    end

    def <<(data)
      data.is_a?(Array) ? @data += data : @data << data
    end

    def data
      @data.pack('c*')
    end

    def byte_range
      (start_byte..end_byte)
    end

    def final_part?
      multi_part? ? end_byte == total_size : true
    end

    def multi_part?
      # part_total will be nil if total= attribute isn't found
      !!@multi_part || (part_total || 0) > 1
    end

    def part_size
      multi_part? ? @part_size : @total_size
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
        head << "total=#{part_total}" if multi_part?
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
      line.chomp!("\s")

      res = line[/\sline\=(\d*)/, 1]
      part.line_width = res.to_i unless res.nil?

      res = line[/\spart\=(\d*)/, 1]
      part.part_num = res.to_i unless res.nil?

      # NOTE: total was not part of the spec until v1.2
      res = line[/\stotal\=(\d*)/, 1]
      part.part_total = res.to_i unless res.nil?

      res = line[/\ssize\=(\d*)/, 1]
      part.total_size = res.to_i unless res.nil?

      res = line[/\sname\=(.*)$/, 1]
      part.name = res unless res.nil?
    end

    def self.parse_ypart(part, line)
      line.chomp! # strip newline chars

      res = line[/\sbegin\=(\d*)/, 1]
      part.start_byte = res.to_i unless res.nil?

      res = line[/\send\=(\d*)/, 1]
      part.end_byte = res.to_i unless res.nil?
    end

    def self.parse_yend(part, line)
      line.chomp! # strip newline chars

      res = line[/\ssize\=(\d*)/, 1]
      part.part_size = res.to_i unless res.nil?

      res = line[/\spart\=(\d*)/, 1]
      part.part_num = res.to_i unless res.nil?

      res = line[/\spcrc32\=(\w*)/, 1]
      part.pcrc32 = res.to_i(16) unless res.nil?

      res = line[/\scrc32\=(\w*)/, 1]
      part.crc32 = res.to_i(16) unless res.nil?
    end
  end
end
