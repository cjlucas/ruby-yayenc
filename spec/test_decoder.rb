require 'test/unit'
require 'pathname'

require_relative 'helper'
require 'yayenc'

class TestDecoderSinglePart < Test::Unit::TestCase
  include YAYEncSpecHelper

  def test_decode_01
    encoded_file = 'enc1.txt'
    decoded_file = 'dec1.txt'

    sio = StringIO.new
    dec = YAYEnc::Decoder.new(sio)
    dec.feed(File.read(file_path(encoded_file)))

    sio.rewind
    data = sio.read

    expected_data = File.read(file_path(decoded_file))

    assert_equal expected_data.size, data.size

    (0...expected_data.size).each { |i| assert_equal expected_data[i], data[i] }
  end
end
