# frozen_string_literal: true

require_relative '../lib/covenant'

module MyBusinessLogic
  # You have to define your types. No types are provided internally.
  # Becuse in business logic there is no such a thing as string, int, boolean, etc
  # A Prop is a type with a name and a validator. So I do more than just checking the type.
  # I make sure it follows the rules defined.
  module Props
    ID    = Covenant.Prop(:id, Covenant.Validate.coerce(:integer))
    Token = Covenant.Prop(:token,
                          Covenant.Validate.coerce(:string)
                          .and_then(Covenant.Validate.length(min: 4)))
    Name  = Covenant.Prop(:name, Covenant.Validate.coerce(:string))
    Email = Covenant.Prop(:email, Covenant.Validate.coerce(:string))
  end

  # With you types defined, you can create your structs.
  module Structs
    include Props

    User = Covenant.Struct(:user, ID + Name + Email)
  end

  # With your structs now you can create your contracts.
  # What goes in and what goes out
  module Contracts
    include Structs

    GetTokenContract      = Covenant.Contract(:GetToken, ID.struct, Token.struct)
    GetUserContract       = Covenant.Contract(:GetUser, Token.struct, User)
    GetOwnerContract      = Covenant.Contract(:GetOwner, Token.struct, User)
    AuthorizeUserContract = Covenant.Contract(:AuthorizeUser, ID.struct, Covenant::Types::Void)
    LogMessageContract    = Covenant.Contract(:LogMessage,
                                              Covenant::Types::Any,
                                              Covenant::Types::Void)

    NotifySuccessContract = Covenant.Contract(:NotifySuccess,
                                              Covenant::Types::Any,
                                              Covenant::Types::Void)
    NotifyFailureContract = Covenant.Contract(:NotifyFailure,
                                              Covenant::Types::Any,
                                              Covenant::Types::Void)
  end

  # This is your business logic.
  # With you contracts defined, you define the flow of execution.
  module Chains
    include Contracts

    GetUserById = GetTokenContract
                  .and_then(GetUserContract)
                  .tee(AuthorizeUserContract)
                  .tee(LogMessageContract)
                  .tee(
                    Covenant::Contracts.match(
                      success: NotifySuccessContract,
                      failure: NotifyFailureContract
                    )
                  )
  end
end

module MyBusinessImplementation
  Layer = Covenant.Layer do |l|
    l.register(:GetToken,       ->(_input) { { token: 'Token123' } })
    l.register(:GetUser,        ->(_input) { { name: 'Fede', email: 'fede@xxx.com' } })
    l.register(:AuthorizeUser,  ->(_input) { true })
    l.register(:LogMessage,     ->(input)  { puts "Log #{input}" })
    l.register(:NotifySuccess,  ->(_input) { puts 'Success!' })
    l.register(:NotifyFailure,  ->(_input) { puts 'Failure!' })
  end

  Runtime = Covenant.Runtime(Layer)
end

result = MyBusinessImplementation::Runtime.call(
  MyBusinessLogic::Chains::GetUserById,
  { id: '1' }
)

puts '=> Success:'
ap result.success?
puts '=> Value:'
ap result.value
puts '=> Unwraped:'
ap result.unwrap
