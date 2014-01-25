require_relative 'test_helper'

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


    part = YAYEnc::Part.parse(parts[0].to_s)
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

    part = YAYEnc::Part.parse(parts[1].to_s)
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

  def test_part_parser_03
    part = YAYEnc::Part.parse(File.read(file_path('enc1.txt')))

    assert_equal 'enc1.txt',  part.name
    assert_equal 584,         part.total_size
    assert_equal 3738345295,  part.crc32
    assert_equal 1,           part.start_byte
    assert_equal 584,         part.end_byte
  end

  def test_part_parser_04
    part = YAYEnc::Part.parse(File.read(file_path('enc2.p1.txt')))
    assert_equal 'joystick.jpg',  part.name
    assert_equal 1,               part.part_num
    assert_equal nil,             part.part_total
    assert_equal 1,               part.start_byte
    assert_equal 11250,           part.end_byte
    assert_equal 11250,           part.part_size
    assert_equal 19338,           part.total_size
    assert_equal 3215875083,      part.pcrc32

    part = YAYEnc::Part.parse(File.read(file_path('enc2.p2.txt')))
    assert_equal 'joystick.jpg',  part.name
    assert_equal 2,               part.part_num
    assert_equal nil,             part.part_total
    assert_equal 11251,           part.start_byte
    assert_equal 19338,           part.end_byte
    assert_equal 8088,            part.part_size
    assert_equal 19338,           part.total_size
    assert_equal 2896650307,      part.pcrc32

    assert part.multi_part?
    assert part.final_part?
  end
end
