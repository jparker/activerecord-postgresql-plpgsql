# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |spec|
  spec.name          = 'activerecord-postgresql-plpgsql'
  spec.version       = '0.0.2'
  spec.authors       = ['John Parker']
  spec.email         = ['jparker@urgetopunt.com']
  spec.summary       = %q{ActiveRecord::Migration helpers for generating PL/pgSQL functions.}
  spec.description   = %q{Provides migration helper methods like #create_function, #remove_function, etc.}
  spec.homepage      = 'https://github.com/jparker/activerecord-postgresql-plpgsql'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.required_ruby_version = '>= 2.1'

  spec.add_dependency 'activerecord', '>= 4.0.0', '< 5.0.0'
  spec.add_dependency 'pg'

  spec.add_development_dependency 'bundler', '~> 1.7'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'minitest'
  spec.add_development_dependency 'appraisal'
end
