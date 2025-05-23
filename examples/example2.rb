# frozen_string_literal: true

require_relative '../lib/covenant'

# You have to define your types. No types are provided internally.
# Becuse in business logic there is no such a thing as string, int, boolean, etc
# A Prop is a type with a name and a validator. So I do more than just checking the type.
# I make sure it follows the rules defined.
module Props
  ID    = Covenant.Scalar(:id, Covenant.Validate.coerce(:integer))
  Token = Covenant.Scalar(:token,
                          Covenant.Validate.coerce(:string)
                          .and_then(Covenant.Validate.length(min: 4)))
  Name  = Covenant.Scalar(:name, Covenant.Validate.coerce(:string))
  Email = Covenant.Scalar(:email, Covenant.Validate.coerce(:string))
end

# With you types defined, you can create your structs.
module Structs
  include Props

  User = Covenant.Schema(:user, ID + Name + Email)
end

# With your structs now you can create your contracts.
# What goes in and what goes out
module Contracts
  include Structs

  GetTokenContract      = Covenant.Contract(:GetToken, ID.struct, Token.struct)
  GetUserContract       = Covenant.Contract(:GetUser, Token.struct, User)
  GetOwnerContract      = Covenant.Contract(:GetOwner, Token.struct, User)
  AuthorizeUserContract = Covenant.Contract(:AuthorizeUser, ID.struct, Covenant::Types::Void)
  LogMessageContract    = Covenant.Contract(:LogMessage, Covenant::Types::Any,
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

  # GetUserById2 = Covenant::Contracts.pipe(
  #   GetTokenContract,
  #   GetUserContract,
  #   Covenant::Contracts.tee(AuthorizeUserContract),
  #   Covenant::Contracts.tee(LogMessageContract),
  #   Covenant::Contracts.tee(
  #     Covenant::Contracts.match(
  #       success: NotifySuccessContract,
  #       failure: NotifyFailureContract
  #     )
  #   )
  # )
end

# GetTokenContract
#   >(token)> GetUserContract
#       >(user)> Tee(AuthorizeUser)
#         >(user)> Tee(LogMessageContract)
#           >(user)> Match()
#
# NOTE: Istead of creating a three showing the errors show just the nodes with errors.
# Printing everything might get cumbersom to read

# Covenant::Ast::Ast.new(Contracts::GetTokenContract).tap do |ast|
#   puts Covenant::Ast::AstShortPrinter.new(ast.to_ast).print
# end

# Covenant::Ast::Ast.new(Chains::GetUserById).tap do |ast|
#   # puts Covenant::Ast::AstShortPrinter.new(ast.to_ast).print
#   # puts Covenant::Ast::AstThreePrinter.new(ast.to_ast).print
#   puts Covenant::Ast::AstChecker.new(ast.to_ast).check
# end

Covenant::Ast::Ast.new(
  Contracts::GetUserContract.and_then(Contracts::GetTokenContract)
).tap do |ast|
  puts Covenant::Ast::AstChecker.new(ast.to_ast).check
end

puts 'done'
