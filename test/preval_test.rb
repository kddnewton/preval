require 'test_helper'

class PrevalTest < Minitest::Test
  Dir[File.join(__dir__, 'cases', '*.test')].each do |filepath|
    define_method(:"test_#{File.basename(filepath, '.test')}") do
      input, output = File.read(filepath).split("---\n")
      assert_process input, output
    end
  end

  EXPECTED_EVENTS = %i[
    alias_error
    arg_ambiguous
    assign_error
    class_name_error
    excessed_comma
    heredoc_dedent
    magic_comment
    mlhs_new
    number_arg
    operator_ambiguous
    param_error
    parse_error
    stmts_new
  ]

  def test_event_types
    methods =
      (Ripper::PARSER_EVENTS - EXPECTED_EVENTS).map { |event| :"to_#{event}" }

    assert_empty methods - Preval::Node.instance_methods
  end

  def test_arithmetic
    assert_process '3 + 4', '7'

    assert_process 'a + 0', 'a'
    assert_process '0 + a', 'a'

    assert_process 'a * 1', 'a'
    assert_process '1 * a', 'a'

    assert_process 'a ** 1', 'a'
    assert_process '1 ** a', '1'

    assert_process '5 ** 0', '1'
    assert_process '-5 ** 0', '-1'
  end

  def test_loops_while_true
    assert_process <<~INPUT, <<~OUTPUT
      while true
        puts 'Hello, world!'
      end
    INPUT
      loop do
      puts "Hello, world!"
      end
    OUTPUT
  end

  def test_loops_for
    assert_process <<~INPUT, <<~OUTPUT
      for foo in [1, 2, 3]
        foo
      end
    INPUT
      [1, 2, 3].each do |foo|
      foo
      end
    OUTPUT
  end

  def test_micro_reverse_each
    assert_process '[].reverse.each', '[].reverse_each'
    assert_process 'foo.reverse.each', 'foo.reverse_each'

    assert_process 'Foo.reverse.each', 'Foo.reverse.each'
  end

  def test_micro_gsub_tr
    assert_process 'foo.gsub("a", "b")', 'foo.tr("a", "b")'
  end
end
