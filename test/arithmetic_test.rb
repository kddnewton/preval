require 'test_helper'

class ArithmeticTest < Minitest::Test
  def test_basic_arithmetic
    assert_process '3 + 4', '7'
    assert_process '3 * 4', '12'
  end

  def test_addition_identity
    assert_process 'a + 0', 'a'
    assert_process '0 + a', 'a'
  end

  def test_multiplication_identity
    assert_process 'a * 1', 'a'
    assert_process '1 * a', 'a'
  end

  def test_exponentiation_identity
    assert_process 'a ** 1', 'a'
    assert_process '1 ** a', '1'
  end

  def test_exponentiation_zero
    assert_process '5 ** 0', '1'
    assert_process '-5 ** 0', '-1'
  end
end
