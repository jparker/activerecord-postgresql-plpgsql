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
create_function(:do_something, returns: :trigger) do
  <<-SQL
  BEGIN
    -- ...
    -- PL/pgSQL function body
    -- ...
  END
  SQL
end
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
TODO: Write usage instructions here

## Contributing

1. Fork it ( https://github.com/jparker/activerecord-postgresql-plpgsql/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
