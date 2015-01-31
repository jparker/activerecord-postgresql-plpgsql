require 'test_helper'

class TriggerTest < Minitest::Test
  def test_create_trigger_as_before_hook
    skip
  end

  def test_create_trigger_as_after_hook
    skip
  end

  def test_create_trigger_without_before_or_after_raises_error
    err = assert_raises ArgumentError do
      schema do
        create_trigger :do_it, on: :widgets
      end
    end

    assert_match /:before or :after keyword argument/, err.message
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
end
