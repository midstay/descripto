# Descripto

Descripto is a library to manage short strings that can be attached to a model in Ruby on Rails. It is similar to ActsAsTaggable, but attempts to solve some of the shortcomings of that library.

## Installation

Add descripto to your gemfile with:

`gem 'descripto', git: 'https://github.com/midstay/descripto.git'`

After running `bundle install` you should add and run the migrations

```bash
rake g descripto::install
bin/rails db:migrate
```

## Usage

Include the mixin in the model where you want to add descriptions

E.g.

```ruby
class Person < ApplicationRecord
  include Descripto::Associated
end
```

You also need to specify which associations you want to add like so

```ruby
module Description
  module Types
    INTEREST = "interest"
    NATIONALITY = "nationality"

    def self.all
    constants.map { |name| const_get(name) }
    end
  end
end
```

You can control how many should be available with

```ruby
module Description
  module Limits
    INTEREST = 5
    NATIONALITY = 1
  end
end
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/midstay/descripto. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/midstay/descripto/blob/main/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Descripto project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/midstay/descripto/blob/main/CODE_OF_CONDUCT.md).
