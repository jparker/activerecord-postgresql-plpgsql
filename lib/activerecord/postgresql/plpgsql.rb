require 'active_record/connection_adapters/postgresql_adapter'

ActiveRecord::ConnectionAdapters::PostgreSQLAdapter.class_eval do
  # create_function :name_of_function, as:<<SQL, returns: :trigger
  # BEGIN
  #   -- ...
  #   -- PL/pgSQL function body
  #   -- ...
  # END
  # SQL
  def create_function(name, *args, as:, returns:, replace: false)
    command = replace ? 'CREATE OR REPLACE FUNCTION' : 'CREATE FUNCTION'
    execute \
      "#{command} #{name}(#{args.join(', ')}) RETURNS #{returns} AS $PROC$" \
      " #{as}" \
      " $PROC$ LANGUAGE plpgsql"
  end

  # remove_function :name_of_function
  def remove_function(name, if_exists: false, cascade: false)
    command = if_exists ? 'DROP FUNCTION IF EXISTS' : 'DROP FUNCTION'
    execute "#{command} #{name}() #{'CASCADE' if cascade}"
  end

  # create_trigger :name_of_trigger, before: [:insert, :update], on: 'table_name'
  def create_trigger(name, before: nil, after: nil, of: nil, on:, foreach: :row, execute: name, replace: false)
    before = Array(before)
    after  = Array(after)
    of     = Array(of)

    if before.empty? && after.empty?
      raise ArgumentError, 'missing keyword: before or after'
    elsif !before.empty? && !after.empty?
      raise ArgumentError, 'incompatible keywords: before and after may not be used together'
    end

    if foreach != :statement && foreach != :row
      raise ArgumentError, 'foreach must be one of :statement or :row'
    end

    timing = before.empty? ? 'AFTER' : 'BEFORE'
    contexts = before.empty? ? after : before
    contexts.map! do |context|
      if context == :update && !of.empty?
        "UPDATE OF #{of.join(', ')}"
      else
        context.upcase
      end
    end
    context = "#{timing} #{contexts.join ' OR '}"

    remove_trigger name, on: on, if_exists: true if replace
    execute \
      "CREATE TRIGGER #{name} #{context} ON #{on}" \
      " FOR EACH #{foreach.upcase} EXECUTE PROCEDURE #{execute}()"
  end

  # remove_trigger :name_of_trigger, on: 'table_name'
  def remove_trigger(name, on:, if_exists: false)
    command = if_exists ? 'DROP TRIGGER IF EXISTS' : 'DROP TRIGGER'
    execute "#{command} #{name} ON #{on}"
  end
end
