# Prepack

`Prepack` is a gem that hooks into the Ruby compilation process and runs optimizations before it gets loaded by the virtual machine.

Certain optimizations are that are common in compilers are not immediately possible with Ruby on account of Ruby's flexibility. For example, most compilers will run through a process called [constant folding](https://en.wikipedia.org/wiki/Constant_folding) to eliminate the need to perform extraneous operations at runtime (e.g., `5 + 2` in the source can be replaced with `7`). However, because Ruby allows you to override the `Integer#+` method, it's possible that `5 + 2` would not evaluate to `7`. `Prepack` assumes that most developers will not override the `Integer#+` method, and performs optimizations under that assumption.

Users must opt in to each of `Prepack`'s optimizations, as there's no real way of telling whether or not it is 100% safe for any codebase. The more optimizations are allowed to run, the most time and memory savings later. Users can also define their own optimizations by subclassing the `Prepack::Visitor` class and using the existing `Prepack::Node` APIs to replace and update the Ruby AST as necessary.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'prepack'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install prepack

## Usage

At the moment, this gem is a POC and should not be used in production. If you want to experiment with it, you can use the `bootsnap` gem to hook into the compilation process and run `Prepack.process` over the source as it comes through. This will eventually be automated.

Each optimization is generally named for the function it performs, and can be enabled through the `enable!` method on the visitor class.

* `Prepack::Visitors::Arithmetic`
  * replaces constant expressions with their evaluation (e.g., `5 + 2` becomes `7`)
  * replaces certain arithmetic identities with their evaluation (e.g., `a * 1` becomes `a`)
* `Prepack::Visitors::Loops`
  * replaces `while true ... end` loops with `loop do ... end` loops

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/kddeisz/prepack.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
