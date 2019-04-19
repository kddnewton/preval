require 'test_helper'

class MicroTest < Minitest::Test
  def test_reverse_each
    assert_process '[].reverse.each', '[].reverse_each'
    assert_process 'foo.reverse.each', 'foo.reverse_each'
    assert_process 'Foo.reverse.each', 'Foo.reverse.each'
  end

  def test_gsub_tr
    assert_process 'foo.gsub("a", "b")', 'foo.tr("a", "b")'
  end

  def test_shuffle_first
    assert_process '[].shuffle.first', '[].sample'
    assert_process 'foo.shuffle.first', 'foo.sample'
    assert_process 'Foo.shuffle.first', 'Foo.shuffle.first'
  end

  def test_map_flatten
    assert_process '[].map { |x| x }.flatten(1)', '[].flat_map { |x|x }'
    assert_process 'foo.map { |x| x }.flatten(1)', 'foo.flat_map { |x|x }'
    assert_process 'Foo.map { |x| x }.flatten(1)', 'Foo.map { |x|x }.flatten(1)'
  end
end
