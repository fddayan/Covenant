# # frozen_string_literal: true

# require 'covenant'

# module MySchemas
#   IdSchema = Dry::Schema.Params do
#     required(:id).filled(:string)
#   end

#   UserSchema = Dry::Schema.Params do
#     required(:name).filled(:string)
#     required(:email).filled(:string)
#   end

#   TokenSchema = Dry::Schema.Params { required(:token).filled(:string) }
# end

# module MyContracts
#   include MySchemas

#   GetTokenContract      = Contract(:GetToken, IdSchema, TokenSchema)

#   GetUserContract       = Contract(:GetUser, TokenSchema, UserSchema)

#   GetOwnerContract      = Contract(:GetOwner, TokenSchema, UserSchema)

#   AuthorizeUserContract = Contract(:AuthorizeUser, IdSchema, Void)

#   LogMessageContract    = Contract(:LogMessage, Any, Void)
# end

# module MyTransformers
#   GetUserIdFromUserTransformer = Transformer(UserSchema, IdSchema) do |user|
#     user[:id]
#   end
# end

# ContractComposition1 = MyContracts::GetToken
#                        .and_then(MyTransformers::GetUserIdFromUserTransformer)
#                        .and_then(
#                          MyContracts::GetUserContract
#                         .or_else(MyContracts::GetOwnerContract)
#                        )
#                        .tee(MyContracts::AuthorizeUserContracg.retry(3))
#                        .tee(MyContracts::LogMessageContract.timeout(1))

# runtme = Covenant.runtime.layer do |l|
#   l.register(:GetToken, ->(input) { input[:token] })
#   l.register(:GetUser, ->(input) { input[:user] })
#   l.register(:GetOwner, ->(input) { input[:owner] })
#   l.register(:AuthorizeUser, ->(input) { input[:user_id] })
#   l.register(:LogMessage, ->(input) { puts "Log: #{input}" })
# end

# runtme.call(ContractComposition1, { id: '1' }).tap do |result|
#   puts "Result: #{result}"
# end
