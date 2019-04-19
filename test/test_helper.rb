$LOAD_PATH.unshift File.expand_path('../lib', __dir__)
require 'preval'

Preval::Visitors::Arithmetic.enable!
Preval::Visitors::Loops.enable!
Preval::Visitors::Micro.enable!

require 'minitest/autorun'

class Minitest::Test
  private

  def assert_process(input, output)
    assert_equal Preval.process(input).chomp, output.chomp
  end
end
