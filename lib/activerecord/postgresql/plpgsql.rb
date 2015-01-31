require 'active_record/connection_adapters/postgresql_adapter'

ActiveRecord::ConnectionAdapters::PostgreSQLAdapter.class_eval do
  # create_function(:do_a_thing, as:<<SQL, returns: :trigger)
  # BEGIN
  #   -- ...
  #   -- PL/pgSQL function body
  #   -- ...
  # END
  # SQL
  def create_function(name, *args, as:, returns:, replace: true)
    command = replace ? 'CREATE OR REPLACE FUNCTION' : 'CREATE FUNCTION'
    execute \
      "#{command} #{name}(#{args.join(', ')}) RETURNS #{returns} AS $PROC$" \
      " #{as}" \
      " $PROC$ LANGUAGE plpgsql"
  end

  # remove_function(:do_a_thing)
  def remove_function(name, must_exist: false, cascade: false)
    command = must_exist ? 'DROP FUNCTION' : 'DROP FUNCTION IF EXISTS'
    execute "#{command} #{name}() #{'CASCADE' if cascade}"
  end

  # create_trigger(:do_a_thing, before: [:insert, :update], on: :widgets)
  def create_trigger(name, on:, before: nil, after: nil, execute: name, replace: true)
    if before && !Array(before).empty?
      context = "BEFORE #{Array(before).map(&:upcase).join(' OR ')}"
    elsif after && !Array(after).empty?
      context = "AFTER #{Array(after).map(&:upcase).join(' OR ')}"
    else
      raise ArgumentError, 'must provide either :before or :after keyword argument'
    end

    remove_trigger(name, on: on) if replace
    execute \
      "CREATE TRIGGER #{name} #{context} ON #{on}" \
      " FOR EACH ROW EXECUTE PROCEDURE #{execute}()"
  end

  # remove_trigger(:do_a_thing, on: :widgets)
  def remove_trigger(name, on:, must_exist: false)
    command = must_exist ? 'DROP TRIGGER' : 'DROP TRIGGER IF EXISTS'
    execute "#{command} #{name} ON #{on}"
  end
end
