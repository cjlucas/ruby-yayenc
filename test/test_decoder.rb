require_relative 'test_helper'

module TestDecoderSetup
  def setup
    @sio = StringIO.new
    @dec = YAYEnc::Decoder.new(@sio)
  end
end

module TestDecoderCompareData
  def compare_data(data1, data2)
    assert_equal data1.size, data2.size
    assert_equal data1, data2
    #(0...data1.size).each { |i| assert_equal data1[i], data2[i] }
  end
end

class TestDecoderSinglePart < Test::Unit::TestCase
  include YAYEncSpecHelper
  include TestDecoderSetup
  include TestDecoderCompareData


  def test_decode_01
    encoded_file = 'enc1.txt'
    decoded_file = 'dec1.txt'
    expected_data = File.read(file_path(decoded_file))

    @dec.feed(File.read(file_path(encoded_file)))

    assert !@dec.errors?
    assert @dec.done?

    assert_equal 3738345295, @dec.crc32

    @sio.rewind
    compare_data expected_data, @sio.read
  end
end

class TestDecoderMultiPart < Test::Unit::TestCase
  include YAYEncSpecHelper
  include TestDecoderSetup
  include TestDecoderCompareData

  #
  # Test multipart by feeding data in proper order
  #
  def test_decode_01
    expected_data = File.read(file_path('dec2.jpg'))

    @dec.feed(File.read(file_path('enc2.p1.txt')))
    assert !@dec.done?

    @dec.feed(File.read(file_path('enc2.p2.txt')))
    assert @dec.done?
    assert !@dec.errors?

    assert_equal 1285118361, @dec.crc32

    @sio.rewind
    compare_data expected_data, @sio.read
  end

  #
  # Test multipart by feeding data out of order
  #
  def test_decode_02
    expected_data = File.read(file_path('dec2.jpg'))

    @dec.feed(File.read(file_path('enc2.p2.txt')))
    assert !@dec.done?
    @dec.feed(File.read(file_path('enc2.p1.txt')))
    assert @dec.done?
    assert !@dec.errors?


    assert_equal 1285118361, @dec.crc32

    @sio.rewind
    compare_data expected_data, @sio.read
  end

  def test_decode_03
    expected_data = File.read(file_path('dec3.bin'))

    @dec.feed(File.read(file_path('dec3.bin-001.ync')))
    assert !@dec.done?
    @dec.feed(File.read(file_path('dec3.bin-005.ync')))
    assert !@dec.done?
    @dec.feed(File.read(file_path('dec3.bin-003.ync')))
    assert !@dec.done?
    @dec.feed(File.read(file_path('dec3.bin-006.ync')))
    assert !@dec.done?
    @dec.feed(File.read(file_path('dec3.bin-002.ync')))
    assert !@dec.done?
    @dec.feed(File.read(file_path('dec3.bin-004.ync')))
    assert @dec.done?
    assert !@dec.errors?

    assert_equal 933888609, @dec.crc32

    @sio.rewind
    compare_data expected_data, @sio.read
  end
end

class TestDecoderDataVerification < Test::Unit::TestCase
  include YAYEncSpecHelper
  include TestDecoderSetup

  def setup
    super

    # feed good data before bad so we can check if #errors? changes
    @dec.feed(File.read(file_path('dec3.bin-002.ync')))

    @data6_bytes = File.read(file_path('dec3.bin-006.ync')).bytes
  end


  def test_bad_data
    # change byte from 143 to 99
    @data6_bytes[100] = 99

    assert !@dec.errors?
    @dec.feed(@data6_bytes.pack('c*'))
    assert @dec.errors?
  end

  def test_bad_size
    # add byte
    @data6_bytes.insert(100, 99)

    assert !@dec.errors?
    @dec.feed(@data6_bytes.pack('c*'))
    assert @dec.errors?
  end

  def test_bad_crc32
    # change crc32 value (from 37AA0261 to 37AA0262)
    @data6_bytes[-3] = 50

    @dec.feed(File.read(file_path('dec3.bin-001.ync')))
    @dec.feed(File.read(file_path('dec3.bin-002.ync')))
    @dec.feed(File.read(file_path('dec3.bin-003.ync')))
    @dec.feed(File.read(file_path('dec3.bin-004.ync')))
    @dec.feed(File.read(file_path('dec3.bin-005.ync')))

    assert !@dec.errors?
    @dec.feed(@data6_bytes.pack('c*'))
    assert @dec.errors?
  end

  def test_bad_pcrc32
    # change pcrc32 value (from 7DDB04A9 to 7DDB04B9)
    @data6_bytes[-19] = 66

    assert !@dec.errors?
    @dec.feed(@data6_bytes.pack('c*'))
    assert @dec.errors?
  end
end
