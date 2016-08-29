require 'test_helper'

class FunctionTest < Minitest::Test
  def test_create_function
    schema do
      create_function :forty_two, as: 'BEGIN RETURN 42; END', returns: :integer
    end
    assert_equal 42, Integer(select_value('SELECT forty_two()'))
  end

  def test_create_function_with_arguments
    schema do
      create_function :adder, :integer, :integer, as: 'BEGIN RETURN $1+$2; END', returns: :integer
    end

    assert_equal 42, Integer(select_value('SELECT adder(20, 22)'))
  end

  def test_create_function_with_named_arguments
    schema do
      create_function :adder, 'a integer', 'b integer',
        as: 'BEGIN RETURN a+b; END', returns: :integer
    end

    assert_equal 43, Integer(select_value('SELECT adder(42, 1)'))
  end

  def test_create_or_replace_function
    schema do
      create_function :forty_two, as: 'BEGIN RETURN -1; END', returns: :integer
      create_function :forty_two, as: 'BEGIN RETURN 42; END', returns: :integer, replace: true
    end
    assert_equal 42, Integer(select_value('SELECT forty_two()'))
  end

  def test_create_function_when_matching_function_exists_raises_error
    err = assert_raises ActiveRecord::StatementInvalid do
      schema do
        create_function :forty_two, as: 'BEGIN RETURN -1; END', returns: :integer
        create_function :forty_two, as: 'BEGIN RETURN 42; END', returns: :integer, replace: false
      end
    end
    assert_match /PG::DuplicateFunction/, err.message
  end

  def test_remove_function
    schema do
      create_function :forty_two, as: 'BEGIN RETURN 42; END', returns: :integer
    end
    select_value('SELECT forty_two()')

    schema do
      remove_function :forty_two
    end
    err = assert_raises ActiveRecord::StatementInvalid do
      select_value 'SELECT forty_two()'
    end
    assert_match /PG::UndefinedFunction/, err.message
  end

  def test_remove_function_with_parameters
    schema do
      create_function :adder, 'a integer', 'b integer',
        as: 'BEGIN RETURN a+b; END', returns: :integer
    end
    select_value('SELECT adder(42, 1)')

    schema do
      remove_function :adder, 'a integer', 'b integer'
    end
    err = assert_raises ActiveRecord::StatementInvalid do
      select_value 'SELECT adder(42, 1)'
    end
    assert_match /PG::UndefinedFunction/, err.message
  end

  def test_remove_function_when_function_does_not_exist_raises_error
    err = assert_raises ActiveRecord::StatementInvalid do
      schema do
        remove_function :forty_two
      end
    end

    assert_match /PG::UndefinedFunction/, err.message
  end

  def test_remove_function_with_if_exists
    schema do
      remove_function :forty_two, if_exists: true
    end

    # If no exception has been raised, this test passes.
    pass
  end

  def test_remove_function_with_dependent_objects_raises_error
    schema do
      create_table :widgets
      create_function :forty_two, as: 'BEGIN RETURN NULL; END', returns: :trigger
      create_trigger :forty_two, on: :widgets, before: :insert
    end

    err = assert_raises ActiveRecord::StatementInvalid do
      schema do
        remove_function :forty_two
      end
    end

    assert_match /PG::DependentObjectsStillExist/, err.message
  end

  def test_remove_function_with_cascade
    schema do
      create_table :widgets
      create_function :forty_two, as: 'BEGIN RETURN NULL; END', returns: :trigger
      create_trigger :forty_two, on: :widgets, before: :insert
    end

    schema do
      remove_function :forty_two, cascade: true
    end

    # If no exception has been raised, this test passes.
    pass
  end
end
