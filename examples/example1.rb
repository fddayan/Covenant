# frozen_string_literal: true

# # frozen_string_literal: true

require_relative '../lib/covenant'

module MyBusinessLogic
  module Props
    ID    = Covenant.Prop(:id, Covenant.Validate.coerce(:integer))
    Token = Covenant.Prop(:token,
                          Covenant.Validate.coerce(:string)
                          .and_then(Covenant.Validate.length(min: 4)))
    Name  = Covenant.Prop(:name, Covenant.Validate.coerce(:string))
    Email = Covenant.Prop(:email, Covenant.Validate.coerce(:string))
  end

  module Structs
    include Props

    User = Covenant.Struct(:user, ID + Name + Email)
  end

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
    l.register(:GetUser,        ->(_input) { { name: 'Fede', email: 'fede@gmail.com' } })
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
