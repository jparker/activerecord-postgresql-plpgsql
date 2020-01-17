# [![Build Status](https://travis-ci.org/jparker/activerecord-postgresql-plpgsql.svg?branch=master)](https://travis-ci.org/jparker/activerecord-postgresql-plpgsql)

# ActiveRecord::Migration support for PostgreSQL triggers/functions

This gem provides helpers for creating and removing PL/pgSQL functions and
triggers within a PostgreSQL database.

This is a wildly naïve implementation that has only been carried far enough
to ease my own pain in creating functions and triggers from within
migrations.

*Use at your own risk.*

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'activerecord-postgresql-plpgsql'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install activerecord-postgresql-plpgsql

## Usage

```ruby
create_function(:do_something, as: <<~SQL, returns: :trigger)
  BEGIN
    -- ...
    -- PL/pgSQL function body
    -- ...
  END
SQL
```

```ruby
remove_function(:do_something)
```

```ruby
create_trigger(:do_something, before: [:insert, :update], on: :widgets)
```

```ruby
remove_trigger(:do_something, on: :widgets)
```

## Development

If you don't have PostgreSQL running, you can launch an ephemeral instance
running in a container:

```bash
$ docker run -p 5432:5432 --rm postgres
```

Use the `DB` and `DB_USERNAME` environment variables to specify the name of the
database and the role to use when connecting to PostgreSQL. (The example below
uses the default values assigned to container instances.)

```bash
$ bundle exec rake test DB_USERNAME=postgres DB=postgres
```

Interrupt the container when the tests are complete. (The `--rm` option passed
to `docker run` should clean up the image afterwards.)

## Contributing

1. Fork it ( https://github.com/jparker/activerecord-postgresql-plpgsql/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
