require 'test_helper'

class PrepackTest < Minitest::Test
  Dir[File.join(__dir__, 'cases', '*.test')].each do |filepath|
    define_method(:"test_#{File.basename(filepath, '.test')}") do
      input, output = File.read(filepath).split("---\n")
      assert_equal output, process(input)
    end
  end

  def test_arithmetic
    assert_equal '7', process('3 + 4').strip
  end

  def test_loops
    input = <<~RUBY
      while true
        puts 'Hello, world!'
      end
    RUBY

    output = <<~RUBY
      loop do
      puts "Hello, world!"
      end
    RUBY

    assert_equal output, process(input)
  end

  private

  def process(source)
    Prepack.process(source)
  end
end
