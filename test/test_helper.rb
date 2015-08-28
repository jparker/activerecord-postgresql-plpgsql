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

class Minitest::Test
  def setup
    connection.begin_db_transaction
  end

  def teardown
    connection.rollback_db_transaction
  end

  private

  def connection
    ActiveRecord::Base.connection
  end

  def schema(&block)
    ActiveRecord::Schema.define do
      self.verbose = false
      instance_eval(&block)
    end
  end

  def select_value(*args)
    connection.select_value(*args)
  end
end