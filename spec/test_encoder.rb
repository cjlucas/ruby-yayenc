require 'test/unit'
require 'pathname'

require_relative 'helper'
require 'yayenc'

class TestEncoderSinglePart < Test::Unit::TestCase
  include YAYEncSpecHelper

  def test_part_values
    parts = YAYEnc::Encoder.encode(file_path('dec1.txt'))

    assert_equal 1, parts.size

    assert_equal 'dec1.txt',  parts.first.name
    assert_equal 584,         parts.first.total_size
    assert_equal 3738345295,  parts.first.crc32
    assert_equal 1,           parts.first.start_byte
    assert_equal 584,         parts.first.end_byte
  end
end

class TestEncoderMultiPart < Test::Unit::TestCase
  include YAYEncSpecHelper

  def test_part_values
    parts = YAYEnc::Encoder.encode(file_path('dec2.jpg'),
                                   line_width: 128,
                                   part_size: 11250)

    assert_equal 2, parts.size

    assert_equal 'dec2.jpg',  part[0].name
    assert_equal 1,           part[0].part_num
    assert_equal 2,           part[0].part_total
    assert_equal 1,           part[0].start_byte
    assert_equal 11250,       part[0].end_byte
    assert_equal 11250,       part[0].part_size
    assert_equal 19338,       part[0].total_size
    assert_equal 3215875083,  part[0].pcrc32

    assert part.multi_part?
    assert !part.final_part?

    assert_equal 'dec2.jpg',  part[1].name
    assert_equal 2,           part[1].part_num
    assert_equal 2,           part[1].part_total
    assert_equal 11251,       part[1].start_byte
    assert_equal 19338,       part[1].end_byte
    assert_equal 8088,        part[1].part_size
    assert_equal 19338,       part[1].total_size
    assert_equal 2896650307,  part[1].pcrc32

    assert part.multi_part?
    assert part.final_part?

  end
end
