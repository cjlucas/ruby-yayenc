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

  # encoding of dec3.bin was done by an external tool (yencode)
  def test_part_parser_05
    part = YAYEnc::Part.parse(File.read(file_path('dec3.bin-001.ync')))
    assert_equal 'dec3.bin',      part.name
    assert_equal 128,             part.line_width
    assert_equal 1,               part.part_num
    assert_equal 6,               part.part_total
    assert_equal 1,               part.start_byte
    assert_equal 1000,            part.end_byte
    assert_equal 1000,            part.part_size
    assert_equal 5120,            part.total_size
    assert_equal '81FB413F'.to_i(16),      part.pcrc32
    assert_equal 0,               part.crc32

    assert part.multi_part?
    assert !part.final_part?

    part = YAYEnc::Part.parse(File.read(file_path('dec3.bin-001.ync')))
    assert_equal 'dec3.bin',      part.name
    assert_equal 128,             part.line_width
    assert_equal 1,               part.part_num
    assert_equal 6,               part.part_total
    assert_equal 1,               part.start_byte
    assert_equal 1000,            part.end_byte
    assert_equal 1000,            part.part_size
    assert_equal 5120,            part.total_size
    assert_equal '81FB413F'.to_i(16),      part.pcrc32
    assert_equal 0,               part.crc32

    assert part.multi_part?
    assert !part.final_part?

    part = YAYEnc::Part.parse(File.read(file_path('dec3.bin-002.ync')))
    assert_equal 'dec3.bin',      part.name
    assert_equal 128,             part.line_width
    assert_equal 2,               part.part_num
    assert_equal 6,               part.part_total
    assert_equal 1001,            part.start_byte
    assert_equal 2000,            part.end_byte
    assert_equal 1000,            part.part_size
    assert_equal 5120,            part.total_size
    assert_equal 'FB069D64'.to_i(16),      part.pcrc32
    assert_equal 0,               part.crc32

    assert part.multi_part?
    assert !part.final_part?

    part = YAYEnc::Part.parse(File.read(file_path('dec3.bin-003.ync')))
    assert_equal 'dec3.bin',      part.name
    assert_equal 128,             part.line_width
    assert_equal 3,               part.part_num
    assert_equal 6,               part.part_total
    assert_equal 2001,            part.start_byte
    assert_equal 3000,            part.end_byte
    assert_equal 1000,            part.part_size
    assert_equal 5120,            part.total_size
    assert_equal '6993E58A'.to_i(16),      part.pcrc32
    assert_equal 0,               part.crc32

    assert part.multi_part?
    assert !part.final_part?

    part = YAYEnc::Part.parse(File.read(file_path('dec3.bin-004.ync')))
    assert_equal 'dec3.bin',      part.name
    assert_equal 128,             part.line_width
    assert_equal 4,               part.part_num
    assert_equal 6,               part.part_total
    assert_equal 3001,            part.start_byte
    assert_equal 4000,            part.end_byte
    assert_equal 1000,            part.part_size
    assert_equal 5120,            part.total_size
    assert_equal '1ED21857'.to_i(16),      part.pcrc32
    assert_equal 0,               part.crc32

    assert part.multi_part?
    assert !part.final_part?

    part = YAYEnc::Part.parse(File.read(file_path('dec3.bin-005.ync')))
    assert_equal 'dec3.bin',      part.name
    assert_equal 128,             part.line_width
    assert_equal 5,               part.part_num
    assert_equal 6,               part.part_total
    assert_equal 4001,            part.start_byte
    assert_equal 5000,            part.end_byte
    assert_equal 1000,            part.part_size
    assert_equal 5120,            part.total_size
    assert_equal 'B5A31476'.to_i(16),      part.pcrc32
    assert_equal 0,               part.crc32

    assert part.multi_part?
    assert !part.final_part?

    part = YAYEnc::Part.parse(File.read(file_path('dec3.bin-006.ync')))
    assert_equal 'dec3.bin',      part.name
    assert_equal 128,             part.line_width
    assert_equal 6,               part.part_num
    assert_equal 6,               part.part_total
    assert_equal 5001,            part.start_byte
    assert_equal 5120,            part.end_byte
    assert_equal 120,             part.part_size
    assert_equal 5120,            part.total_size
    assert_equal '7DDB04A9'.to_i(16),      part.pcrc32
    assert_equal '37AA0261'.to_i(16),      part.crc32

    assert part.multi_part?
    assert part.final_part?
  end
end
