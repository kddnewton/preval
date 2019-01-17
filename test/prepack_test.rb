require 'test_helper'

class PrepackTest < Minitest::Test
  Dir[File.join(__dir__, 'cases', '*.test')].each do |filepath|
    input, output = File.read(filepath).split("---\n")

    define_method(:"test_#{File.basename(filepath)}") do
      assert_equal output, process(input)
    end
  end

  private

  def process(source)
    Prepack.process(source)
  end
end
