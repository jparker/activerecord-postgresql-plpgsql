require 'test_helper'

class TriggerTest < Minitest::Test
  def test_create_trigger_as_before_hook
    schema do
      create_table(:foo) { |t| t.integer :bar }
      create_function :foo, as: 'BEGIN NEW.bar = 42; RETURN NEW; END', returns: :trigger
      create_trigger :foo, before: :insert, on: :foo, execute: :foo
    end

    execute 'INSERT INTO foo(bar) VALUES(101)'
    assert_equal 42, Integer(select_value('SELECT bar FROM foo LIMIT 1'))
    execute 'UPDATE foo SET bar = 101'
    assert_equal 101, Integer(select_value('SELECT bar FROM foo LIMIT 1'))
  end

  def test_create_trigger_as_before_hook_for_multiple_events
    schema do
      create_table(:foo) { |t| t.integer :bar }
      create_function :foo, as: 'BEGIN NEW.bar = 42; RETURN NEW; END', returns: :trigger
      create_trigger :foo, before: [:insert, :update], on: :foo, execute: :foo
    end

    execute 'INSERT INTO foo(bar) VALUES(101)'
    assert_equal 42, Integer(select_value('SELECT bar FROM foo LIMIT 1'))

    execute 'UPDATE foo SET bar = 101'
    assert_equal 42, Integer(select_value('SELECT bar FROM foo LIMIT 1'))
  end

  def test_create_trigger_as_after_hook
    schema do
      create_table(:foo) { |t| t.integer :bar }
      create_table(:bar) { |t| t.integer :foo }
      create_function :foo, as: <<-SQL.strip, returns: :trigger
        BEGIN INSERT INTO bar(foo) VALUES(NEW.bar); RETURN NULL; END
      SQL
      create_trigger :foo, after: :insert, on: :foo, execute: :foo
    end

    execute 'INSERT INTO foo(bar) VALUES(42)'
    assert_equal 42, Integer(select_value('SELECT foo FROM bar LIMIT 1'))
  end

  def test_create_trigger_as_after_hook_for_multiple_events
    schema do
      create_table(:foo) { |t| t.integer :bar }
      create_table(:bar) { |t| t.integer :foos_count }
      create_function :foo_count, as: <<-SQL.strip, returns: :trigger
        BEGIN UPDATE bar SET foos_count = (SELECT COUNT(*) FROM foo); RETURN NULL; END
      SQL
      create_trigger :foo_count, after: [:insert, :delete], on: :foo, execute: :foo_count
    end

    execute 'INSERT INTO bar(foos_count) VALUES(0)'
    execute 'INSERT INTO foo(bar) VALUES(42)'
    assert_equal 1, Integer(select_value('SELECT foos_count FROM bar LIMIT 1'))
    execute 'DELETE FROM foo'
    assert_equal 0, Integer(select_value('SELECT foos_count FROM bar LIMIT 1'))
  end

  def test_create_trigger_with_update_column_constraint
    schema do
      create_table(:foo) { |t| t.integer :bar; t.integer :baz; t.integer :froz }
      create_table(:bar) { |t| t.integer :counter }
      create_function :bar_counter, as: <<-SQL.strip, returns: :trigger
        BEGIN UPDATE bar SET counter = counter + 1; RETURN NULL; END
      SQL
      create_trigger :bar_counter, after: :update, of: [:bar, :baz], on: :foo, execute: :bar_counter
    end

    execute 'INSERT INTO foo(bar, baz, froz) VALUES(1, 1, 1)'
    execute 'INSERT INTO bar(counter) VALUES(0)'
    assert_equal 0, Integer(select_value('SELECT counter FROM bar LIMIT 1'))

    execute 'UPDATE foo SET bar = bar + 1'
    assert_equal 1, Integer(select_value('SELECT counter FROM bar LIMIT 1'))

    execute 'UPDATE foo SET baz = baz + 1'
    assert_equal 2, Integer(select_value('SELECT counter FROM bar LIMIT 1'))

    execute 'UPDATE foo SET froz = froz + 1'
    assert_equal 2, Integer(select_value('SELECT counter FROM bar LIMIT 1'))
  end

  def test_create_trigger_without_before_or_after_raises_error
    err = assert_raises ArgumentError do
      schema do
        create_trigger :do_it, on: :foo
      end
    end

    assert_match /missing keyword: before or after/, err.message
  end

  def test_create_trigger_that_fires_once_per_statement
    schema do
      create_table(:foo) { |t| t.integer :bar }
      create_table :bar do |t|
        t.integer :row_counter
        t.integer :stmt_counter
      end
      create_function :row_counter, as: <<-SQL.strip, returns: :trigger
        BEGIN UPDATE bar SET row_counter = row_counter + 1; RETURN NULL; END
      SQL
      create_function :stmt_counter, as: <<-SQL.strip, returns: :trigger
        BEGIN UPDATE bar SET stmt_counter = stmt_counter + 1; RETURN NULL; END
      SQL
      create_trigger :row_counter, after: :insert, on: :foo, foreach: :row
      create_trigger :stmt_counter, after: :insert, on: :foo, foreach: :statement
    end

    execute 'INSERT INTO bar(row_counter, stmt_counter) VALUES(0, 0)'
    execute 'INSERT INTO foo(bar) VALUES(1), (1), (1)'
    assert_equal 3, Integer(select_value('SELECT row_counter FROM bar LIMIT 1'))
    assert_equal 1, Integer(select_value('SELECT stmt_counter FROM bar LIMIT 1'))
  end

  def test_replace_trigger
    skip
  end

  def test_create_trigger_when_matching_trigger_exists_raises_error
    skip
  end

  def test_remove_trigger
    schema do
      create_table(:foo) { |t| t.integer :bar }
      create_function :foo, as: 'BEGIN NEW.bar = 42; RETURN NEW; END', returns: :trigger
      create_trigger :foo, before: :insert, on: :foo, execute: :foo
      remove_trigger :foo, on: :foo
    end

    execute 'INSERT INTO foo(bar) VALUES(101)'
    assert_equal 101, Integer(select_value('SELECT bar FROM foo LIMIT 1'))
  end

  def test_remove_trigger_that_does_not_exist_raises_error
    err = assert_raises ActiveRecord::StatementInvalid do
      schema do
        create_table :foo
        remove_trigger :foo, on: :foo
      end
    end

    assert_match /PG::UndefinedObject/, err.message
  end
end
