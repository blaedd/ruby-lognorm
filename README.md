# Lognorm

A minimal, simplistic, and likely dangerous wrapper around [liblognorm][1], a
library for normalizing logs.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'lognorm'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install lognorm

## Usage

```ruby

# Initialize the library context
ctx = Lognorm.initCtx

# Load some rules from a file
ctx.loadSamples('sample.ruleset')

# Feed it a logline, get a ruby hash back
result = ctx.normalize(log_line)

## Contributing

1. Fork it ( https://github.com/[my-github-username]/ruby-lognorm/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

[1]: http://www.liblognorm.com
