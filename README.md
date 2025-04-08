# Covenant

> [!NOTE]
> Work in progress feedback appreciated

I created this gem inspired by design-by-contract after a lot of frustartion wrintng business logic for a few big projects. I thought there has to be a better way to organize business logic and coordinate. 

Using the word `Service` as a bag for dumping business logic (such as `UserService`, `OrderService`) never clicked with me. I feel there was something wrong I could not understand what the hell whas a service in this terms. 

I love programming and I run my own researchs, so I created this and since 1 line of code says more than 1000 words I want to know what people think about this concept of designing the business logic without implementing the business logic. 

The big difference of this approach vs using interfeces with dependency injection is that you are forced here to NOT implemented the code. You have to define the coordination of the different business parts without the actual implementation. You can reason about what needs to happend and not how it needs to happend. 

**Look at [example1.rb](/examples/example1.rb) to see what I'm talking about**

Inspired by everything that is out there such as

* Effect.ts
* TypeScript
* dry-rb
* Declarative programming
* Monads

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'covenant'
```

And then execute:

```bash
$ bundle install
```

Or install it yourself as:

```bash
$ gem install covenant
```

## Usage

```ruby
require 'covenant'

# Example code here
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/yourusername/covenant.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
