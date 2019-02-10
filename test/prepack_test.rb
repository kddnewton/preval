require 'test_helper'

class PrepackTest < Minitest::Test
  Dir[File.join(__dir__, 'cases', '*.test')].each do |filepath|
    next if %w[method rescue].include?(File.basename(filepath, '.test'))

    define_method(:"test_#{File.basename(filepath, '.test')}") do
      input, output = File.read(filepath).split("---\n")
      assert_equal output, process(input)
    end
  end

  def test_arithmetic
    assert_equal '7', inline('3 + 4')

    assert_equal 'a', inline('a + 0')
    assert_equal 'a', inline('0 + a')

    assert_equal 'a', inline('a * 1')
    assert_equal 'a', inline('1 * a')

    assert_equal 'a', inline('a ** 1')
    assert_equal '1', inline('1 ** a')
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

  def inline(source)
    process(source).chomp
  end

  def process(source)
    Prepack.process(source)
  end
end
