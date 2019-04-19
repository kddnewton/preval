$LOAD_PATH.unshift File.expand_path('../lib', __dir__)
require 'preval'

Preval.enable_all!

require 'minitest/autorun'

class Minitest::Test
  private

  def assert_change(input, output)
    assert_equal output.chomp, Preval.process(input).chomp
  end

  def refute_change(input)
    assert_change input, input
  end
end
