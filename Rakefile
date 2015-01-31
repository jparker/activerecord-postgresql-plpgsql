require 'bundler/gem_tasks'
require 'rake/testtask'

Rake::TestTask.new :test do |t|
  t.libs << 'lib'
  t.pattern = 'test/**/*_test.rb'
end

namespace :db do
  namespace :test do
    desc 'Prepare test database'
    task :prepare do
      system 'createdb', 'activerecord_postgresql_plpgsql'
    end
  end
end

task default: :test
