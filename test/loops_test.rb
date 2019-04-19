require 'test_helper'

class LoopsTest < Minitest::Test
  def test_while_true
    assert_change <<~INPUT, <<~OUTPUT
      while true
        puts 'Hello, world!'
      end
    INPUT
      loop do
      puts "Hello, world!"
      end
    OUTPUT
  end

  def test_for
    assert_change <<~INPUT, <<~OUTPUT
      for foo in [1, 2, 3]
        foo
      end
    INPUT
      [1, 2, 3].each do |foo|
      foo
      end
    OUTPUT
  end
end
