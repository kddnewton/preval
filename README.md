# Preval

`preval` is a gem that hooks into the Ruby compilation process and runs optimizations before it gets loaded by the virtual machine.

Certain optimizations that are common in compilers are not immediately possible with Ruby on account of Ruby's flexibility. For example, most compilers will run through a process called [constant folding](https://en.wikipedia.org/wiki/Constant_folding) to eliminate the need to perform extraneous operations at runtime (e.g., `5 + 2` in the source can be replaced with `7`). However, because Ruby allows you to override the `Integer#+` method, it's possible that `5 + 2` would not evaluate to `7`. `preval` assumes that most developers will not override the `Integer#+` method, and performs optimizations under that assumption.

Users must opt in to each of `preval`'s optimizations, as there's no real way of telling whether or not it is 100% safe for any codebase. The more optimizations are allowed to run, the more time and memory savings later. Users can also define their own optimizations by subclassing the `Preval::Visitor` class and using the existing `Preval::Node` APIs to replace and update the Ruby AST as necessary.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'preval'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install preval

## Usage

If you're using the `bootsnap` gem, `preval` will automatically hook into its compilation step. Otherwise, you'll need to manually call `Preval.process(source)` with your own iseq loader (you can check out [yomikomu](https://github.com/ko1/yomikomu) for an example).

Each optimization is generally named for the function it performs, and can be enabled through the `enable!` method on the visitor class. If you do not explicitly call `enable!` on any optimizations, nothing will change with your source. You can also call `Preval.enable_all!` which will enable every built-in visitor. Be especially careful when doing this.

### `Preval::Visitors::Arithmetic`

Replaces:

  * constant expressions with their evaluation (e.g., `5 + 2` becomes `7`)
  * arithmetic identities with their evaluation (e.g., `a * 1` becomes `a`)

Unsafe if:

  * you overload any of the `Integer` operator methods

### `Preval::Visitors::AttrAccessor`

Replaces:

  * `def foo; @foo; end` with `attr_reader :foo`
  * `def foo=(value); @foo = value; end` with `attr_writer :foo`

Unsafe if:

  * you overload the `attr_reader` method
  * you overload the `attr_writer` method
  * you have custom complex `method_added` logic

### `Preval::Visitors::Fasterer`

Replaces:

  * `.gsub('...', '...')` with `.tr('...', '...')` if the arguments are strings and are both of length 1
  * `.map { ... }.flatten(1)` with `.flat_map { ... }`
  * `.reverse.each` with `.reverse_each` 
  * `.shuffle.first` with `.sample`

Unsafe if:

  * any of the effected methods are overwritten or custom (`gsub` and `tr` for the first one, `map`, `flatten`, and `flat_map` for the second, etc.)

### `Preval::Visitors::Loops`

Replaces:

  * `for ... in ... end` loops with `... each do ... end` loops
  * `while true ... end` loops with `loop do ... end` loops
  * `while false ... end` loops with nothing
  * `until false ... end` loops with `loop do ... end` loops
  * `until true ... end` loops with nothing

Unsafe if:

  * the object over which you're iterating with a `for` loop has a custom `each` method that doesn't do what you'd expect it to do

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/kddeisz/preval.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
