$LOAD_PATH.unshift File.expand_path('../lib', __dir__)

require 'minitest/autorun'
require 'active_record'
require 'activerecord/postgresql/plpgsql'

ActiveRecord::Base.establish_connection({
  adapter:  'postgresql',
  database: 'activerecord_postgresql_plpgsql',
  username: ENV['DB_USERNAME'] || ENV['USER'],
  password: ENV['DB_PASSWORD'],
  host:     'localhost',
  port:     ENV['DB_PORT'] || 5432,
})

class TestPLpgSQL < Minitest::Test
  def setup
    connection.begin_db_transaction
  end

  def teardown
    connection.rollback_db_transaction
  end

  def test_create_function
    ActiveRecord::Schema.define do
      self.verbose = false
      create_function(:forty_two, as: 'BEGIN RETURN 42; END', returns: :integer)
    end

    assert_equal '42', select_value('SELECT forty_two()')
  end

  def test_create_function_with_arguments
    ActiveRecord::Schema.define do
      self.verbose = false
      create_function(:add_two_ints, :integer, :integer, as: 'BEGIN RETURN $1+$2; END', returns: :integer)
    end

    assert_equal '42', select_value('SELECT add_two_ints(20, 22)')
  end

  def test_create_or_replace_function
    ActiveRecord::Schema.define do
      self.verbose = false
      create_function(:forty_two, as: 'BEGIN RETURN -1; END', returns: :integer)
      create_function(:forty_two, as: 'BEGIN RETURN 42; END', returns: :integer, replace: true)
    end

    assert_equal '42', select_value('SELECT forty_two()')
  end

  def test_create_function_when_matching_function_exists_raises_error
    err = assert_raises ActiveRecord::StatementInvalid do
      ActiveRecord::Schema.define do
        self.verbose = false
        create_function(:forty_two, as: 'BEGIN RETURN -1; END', returns: :integer)
        create_function(:forty_two, as: 'BEGIN RETURN 42; END', returns: :integer, replace: false)
      end
    end

    assert_match /PG::DuplicateFunction/, err.message
  end

  def test_remove_function
    err = assert_raises ActiveRecord::StatementInvalid do
      ActiveRecord::Schema.define do
        self.verbose = false
        create_function(:forty_two, as: 'BEGIN RETURN 42; END', returns: :integer)
        remove_function(:forty_two)
      end
      select_value('SELECT forty_two()')
    end

    assert_match /PG::UndefinedFunction/, err.message
  end

  def test_create_trigger_as_before_hook
    skip
  end

  def test_create_trigger_as_after_hook
    skip
  end

  def test_create_trigger_without_before_or_after_raises_error
    skip
  end

  def test_create_trigger_with_explicit_function_name
    skip
  end

  def test_replace_trigger
    skip
  end

  def test_create_trigger_when_matching_trigger_exists_raises_error
    skip
  end

  def test_remove_trigger
    skip
  end

  def test_remove_trigger_that_does_not_exist_raises_error
    skip
  end

  private

  def connection
    ActiveRecord::Base.connection
  end

  def select_value(*args)
    connection.select_value(*args)
  end
end
