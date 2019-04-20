require 'test_helper'

class AttrAccessorTest < Minitest::Test
  def test_attr_reader
    assert_change 'def foo; @foo; end', 'attr_reader :foo'
    refute_change "def foo \n@bar\nend"
  end

  def test_attr_writer
    assert_change 'def foo=(value); @foo = value; end', 'attr_writer :foo'
    refute_change "def foo= (value)\n@bar = value\nend"
  end
end
