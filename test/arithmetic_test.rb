require 'test_helper'

class ArithmeticTest < Minitest::Test
  def test_basic_arithmetic
    assert_change '3 + 4', '7'
    assert_change '3 * 4', '12'
  end

  def test_addition_identity
    assert_change 'a + 0', 'a'
    assert_change '0 + a', 'a'
  end

  def test_multiplication_identity
    assert_change 'a * 1', 'a'
    assert_change '1 * a', 'a'
  end

  def test_exponentiation_identity
    assert_change 'a ** 1', 'a'
    assert_change '1 ** a', '1'
  end

  def test_exponentiation_zero
    assert_change '5 ** 0', '1'
    assert_change '-5 ** 0', '-1'
  end
end
