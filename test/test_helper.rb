$LOAD_PATH.unshift File.expand_path('../lib', __dir__)

require 'minitest/autorun'
require 'active_record'
require 'activerecord/postgresql/plpgsql'

require 'forwardable'
require 'database_cleaner'
require 'minitest/focus'
require 'pry'

ActiveRecord::Base.establish_connection({
  adapter:  'postgresql',
  database: ENV['POSTGRES_DB'] || 'activerecord_postgresql_plpgsql_test',
  username: ENV['POSTGRES_USER'] || 'postgres',
  password: ENV['POSTGRES_PASSWORD'],
  host:     ENV['POSTGRES_HOST'] || 'localhost',
  port:     ENV['POSTGRES_PORT'] || 5432,
})

DatabaseCleaner.strategy = :transaction

class Minitest::Test
  extend Forwardable

  def setup
    DatabaseCleaner.start
  end

  def teardown
    DatabaseCleaner.clean
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

  delegate [:select_all, :select_value, :execute] => :connection
end
