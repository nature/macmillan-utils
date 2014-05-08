# Macmillan::Utils

A collection of useful patterns we use in our Ruby applications.

## Installation

Add this line to your application's Gemfile:

    gem 'macmillan-utils', require: false

And then execute:

    $ bundle

Or install it yourself with:

    $ gem install macmillan-utils

## Usage

### Logger Objects

To build logger objects quickly and easily:

```ruby
require 'macmillan/utils/logger/factory'
require 'macmillan/utils/logger/formatter'

logger = Macmillan::Utils::Logger::Factory.build_logger(:syslog, tag: 'myapp')
logger.formatter = Macmillan::Utils::Logger::Formatter.new
```

See the class documentation for more information:

* [Macmillan::Utils::Logger::Factory](https://github.com/nature/macmillan-utils/blob/master/lib/macmillan/utils/logger/factory.rb)
* [Macmillan::Utils::Logger::Formatter](https://github.com/nature/macmillan-utils/blob/master/lib/macmillan/utils/logger/formatter.rb)

### RSpec Helpers

Add the following to the top of your `spec_helper.rb`:

```ruby
require 'macmillan/utils/rspec/rspec_defaults'
require 'macmillan/utils/rspec/webmock_helper'
require 'macmillan/utils/test_helpers/codeclimate_helper'
require 'macmillan/utils/test_helpers/simplecov_helper'
```

### Cucumber Helpers

Add the following to the top of your `env.rb`:

```ruby
require 'macmillan/utils/cucumber/cucumber_defaults'
require 'macmillan/utils/cucumber/webmock_helper'
require 'macmillan/utils/test_helpers/codeclimate_helper'
require 'macmillan/utils/test_helpers/simplecov_helper'
```

## Contributing

1. Fork it ( https://github.com/[my-github-username]/macmillan-utils/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
