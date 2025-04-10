# Covenant

> [!NOTE]
> Work in progress feedback appreciated


I created this gem inspired by [design-by-contract](https://en.wikipedia.org/wiki/Design_by_contract) after a lot of frustartion writing business logic for big projects. I thought there has to be a better way to organize business logic and coordinate operations. 

Using `services` as a bag for dumping business logic (such as `UserService`, `OrderService`) never made sense to me. I felt there was something wrong. I could not understand what the hell was even a service.

I want to know what people think about this concept of designing the business logic without implementing the business logic. 

The big difference of this approach vs using interfeces with dependency injection is that you are forced here to NOT implemented the code. You have to define operations and coordination of the different business parts without the actual implementation. You can reason about what needs to happend and not how it needs to happend. 

**Look at [example1.rb](/examples/example1.rb) to see what I'm talking about**

There are 3 parts in this library
* Validations (parsing actually)
* Prop
* Struct
* Contract

```
Validations |> Prop |> Struct |> Contract
```

Inspired by:

* Effect.ts
* TypeScript
* dry-rb
* Declarative programming
* Monads

## Show me the code

### Simple
```ruby
# Creating props with validations
Id = Covenant.Prop(:id, Covenant.Validate.coerce(:integer))
Name  = Covenant.Prop(:name, Covenant.Validate.coerce(:string))
Email = Covenant.Prop(:email, Covenant.Validate.coerce(:string))

# Using props to create a struct
User = Covenant.Struct(:user, Id + Name + Email)

# Using Structs to create a Contract with Id is the input and User is the output
GetUserByIdContract = Covenant.Contract(:GetUserById, ID.struct, User)

# Creating the a layer mapping a contract with the actual implementation
Layer = Covenant.Layer do |l|
  l.register(:GetUserById, ->(_input) { { name: 'Fede', email: 'fede@xxx.com' } })
end

# Setting app the Runtime with a layer. Many layers might be passed
Runtime = Covenant.Runtime(Layer)

# Running a contract. Using the contract tag, I get the implementation then I just run it
result = Runtime.call(GetUserByIdContract,{ id: '1' })

puts result.success?
# true
puts result.value
# { name: ValidationResult(...), email: ValidationResul(...) }
puts result.unwrap
# { name: 'fede', email: 'fede@xxx.com'  }
```

### Adding more complex stuff

```ruby
# I define more props
Token = Covenant.Prop(:token, Covenant.Validate.coerce(:string)
                                               .and_then(Covenant.Validate.length(min: 4)))

# I define more contracts
GetIdByTokenContract  = Covenant.Contract(:GetIdByToken, Token.struct, ID.struct)
AuthorizeUserContract = Covenant.Contract(:AuthorizeUser, ID.struct, Covenant::Types::Void)
LogMessageContract    = Covenant.Contract(:LogMessage,Covenant::Types::Any, Covenant::Types::Void)
NotifySuccessContract = Covenant.Contract(:NotifySuccess, Covenant::Types::Any, Covenant::Types::Void)
NotifyFailureContract = Covenant.Contract(:NotifyFailure, Covenant::Types::Any,Covenant::Types::Void)


# I compose a new contract with other chaining other contracts
# GetUserByTokenContract has to Struct input of GetIdByTokenContract and the Struct output of GetUserByIdContract
# so inout is Token and output is user it like defining a contract: GetUserByTokenContract(Token, User)
# tee is like tap. it does not change the output.
# by combining tee with match I create a match that does not change the output
GetUserByTokenContract = GetIdByTokenContract
                        .and_then(GetUserByIdContract)
                        .tee(AuthorizeUserContract)
                        .tee(LogMessageContract)
                        .tee(
                          Covenant::Contracts.match(
                            success: NotifySuccessContract,
                            failure: NotifyFailureContract
                          )
                        )

Layer2 = Covenant.Layer do |l|
  l.register(:GetIdByToken,  ->(_input) { { token: 'Token123' } })
  l.register(:GetUser,       ->(_input) { { name: 'Fede', email: 'fede@xxx.com' } })
  l.register(:AuthorizeUser, ->(_input) { true })
  l.register(:LogMessage,    ->(input)  { puts "Log #{input}" })
  l.register(:NotifySuccess, ->(_input) { puts 'Success!' })
  l.register(:NotifyFailure, ->(_input) { puts 'Failure!' })
end

Runtime2 = Covenant.Runtime(Layer, Layer2)

result = Runtime2.call(GetUserByTokenContract, { id: '1' })
# Prints:
# Log { name: 'fede', email: 'fede@xxx.com'  }
# Success!

puts result.success?
# true
puts result.value
# { name: ValidationResult(...), email: ValidationResul(...) }
puts result.unwrap
# { name: 'fede', email: 'fede@xxx.com'  }
```

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
