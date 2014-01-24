require 'test/unit'
require 'pathname'

require_relative 'helper'
require 'yayenc'

class TestPartParser < Test::Unit::TestCase
  include YAYEncSpecHelper

  def test_part_parser_01
    parts = YAYEnc::Encoder.encode(file_path('dec1.txt'))

    part = YAYEnc::Part.parse(parts.first.to_s)

    assert_equal 'dec1.txt',  part.name
    assert_equal 584,         part.total_size
    assert_equal 3738345295,  part.crc32
    assert_equal 1,           part.start_byte
    assert_equal 584,         part.end_byte
  end
end
