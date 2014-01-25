require 'test/unit'
require 'pathname'

require_relative 'helper'
require 'yayenc'

module TestDecoderCompareData
  def compare_data(data1, data2)
    assert_equal data1.size, data2.size
    assert_equal data1, data2
    #(0...data1.size).each { |i| assert_equal data1[i], data2[i] }
  end
end

class TestDecoderSinglePart < Test::Unit::TestCase
  include YAYEncSpecHelper
  include TestDecoderCompareData

  def setup
    @sio = StringIO.new
    @dec = YAYEnc::Decoder.new(@sio)
  end

  def test_decode_01
    encoded_file = 'enc1.txt'
    decoded_file = 'dec1.txt'
    expected_data = File.read(file_path(decoded_file))

    @dec.feed(File.read(file_path(encoded_file)))


    @sio.rewind
    compare_data expected_data, @sio.read
  end
end

class TestDecoderMultiPart < Test::Unit::TestCase
  include YAYEncSpecHelper
  include TestDecoderCompareData

  def setup
    @sio = StringIO.new
    @dec = YAYEnc::Decoder.new(@sio)
  end

  #
  # Test multipart by feeding data in proper order
  #
  def test_decode_01
    expected_data = File.read(file_path('dec2.jpg'))

    @dec.feed(File.read(file_path('enc2.p1.txt')))
    @dec.feed(File.read(file_path('enc2.p2.txt')))

    @sio.rewind
    compare_data expected_data, @sio.read
  end

  #
  # Test multipart by feeding data out of order
  #
  def test_decode_02
    expected_data = File.read(file_path('dec2.jpg'))

    @dec.feed(File.read(file_path('enc2.p2.txt')))
    @dec.feed(File.read(file_path('enc2.p1.txt')))

    @sio.rewind
    compare_data expected_data, @sio.read
  end
end
