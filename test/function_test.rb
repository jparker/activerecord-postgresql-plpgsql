require 'test_helper'

class FunctionTest < Minitest::Test
  def test_create_function
    schema do
      create_function(:forty_two, as: 'BEGIN RETURN 42; END', returns: :integer)
    end

    assert_equal '42', select_value('SELECT forty_two()')
  end

  def test_create_function_with_arguments
    schema do
      create_function(:add_two_ints, :integer, :integer, as: 'BEGIN RETURN $1+$2; END', returns: :integer)
    end

    assert_equal '42', select_value('SELECT add_two_ints(20, 22)')
  end

  def test_create_or_replace_function
    schema do
      create_function(:forty_two, as: 'BEGIN RETURN -1; END', returns: :integer)
      create_function(:forty_two, as: 'BEGIN RETURN 42; END', returns: :integer, replace: true)
    end

    assert_equal '42', select_value('SELECT forty_two()')
  end

  def test_create_function_when_matching_function_exists_raises_error
    err = assert_raises ActiveRecord::StatementInvalid do
      schema do
        create_function(:forty_two, as: 'BEGIN RETURN -1; END', returns: :integer)
        create_function(:forty_two, as: 'BEGIN RETURN 42; END', returns: :integer, replace: false)
      end
    end

    assert_match /PG::DuplicateFunction/, err.message
  end

  def test_remove_function
    schema do
      create_function(:forty_two, as: 'BEGIN RETURN 42; END', returns: :integer)
      remove_function(:forty_two)
    end

    err = assert_raises ActiveRecord::StatementInvalid do
      select_value('SELECT forty_two()')
    end

    assert_match /PG::UndefinedFunction/, err.message
  end
end
