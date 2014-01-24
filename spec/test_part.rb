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

  def test_part_parser_02
    parts = YAYEnc::Encoder.encode(file_path('dec2.jpg'),
                                   line_width: 128,
                                   part_size: 11250)


    YAYEnc::Part.parse(parts[0].to_s).tap do |part|
      assert_equal 'dec2.jpg',  part.name
      assert_equal 1,           part.part_num
      assert_equal 2,           part.part_total
      assert_equal 1,           part.start_byte
      assert_equal 11250,       part.end_byte
      assert_equal 11250,       part.part_size
      assert_equal 19338,       part.total_size
      assert_equal 3215875083,  part.pcrc32

      assert part.multi_part?
      assert !part.final_part?
    end

    YAYEnc::Part.parse(parts[1].to_s).tap do |part|
      assert_equal 'dec2.jpg',  part.name
      assert_equal 2,           part.part_num
      assert_equal 2,           part.part_total
      assert_equal 11251,       part.start_byte
      assert_equal 19338,       part.end_byte
      assert_equal 8088,        part.part_size
      assert_equal 19338,       part.total_size
      assert_equal 2896650307,  part.pcrc32

      assert part.multi_part?
      assert part.final_part?
    end
  end
end
