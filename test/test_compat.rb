require_relative 'test_helper'

class TestCompat < Test::Unit::TestCase
  def test_range_size
    assert_equal 101, (0..100).size
    assert_equal 100, (0...100).size

    assert_equal 100, (1..100).size
    assert_equal 99, (1...100).size
  end
end
