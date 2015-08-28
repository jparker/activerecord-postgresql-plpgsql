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
  def create_trigger(name, on:, before: nil, after: nil, execute: name, replace: false)
    if before && !Array(before).empty?
      context = "BEFORE #{Array(before).map(&:upcase).join(' OR ')}"
    elsif after && !Array(after).empty?
      context = "AFTER #{Array(after).map(&:upcase).join(' OR ')}"
    else
      raise ArgumentError, 'must provide either :before or :after keyword argument'
    end

    remove_trigger name, on: on, if_exists: true if replace
    execute \
      "CREATE TRIGGER #{name} #{context} ON #{on}" \
      " FOR EACH ROW EXECUTE PROCEDURE #{execute}()"
  end

  # remove_trigger :name_of_trigger, on: 'table_name'
  def remove_trigger(name, on:, if_exists: false)
    command = if_exists ? 'DROP TRIGGER IF EXISTS' : 'DROP TRIGGER'
    execute "#{command} #{name} ON #{on}"
  end
end
