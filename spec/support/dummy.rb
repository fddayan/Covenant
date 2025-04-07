# module Primitives
#   Void = Covenant.Schema(:Void) { optional(:void) }
#   Any = Covenant.Schema(:Any) { optional(:any) }
#   String = Covenant.Schema(:String) { optional(:value).filled(:string) }
# end

module MySchemas
  IdSchema = Covenant.Type({ id: Covenant::Validator::Validation.coerce(:integer) })
  TokenSchema = Covenant.Type({ token: Covenant::Validator::Validation.coerce(:string) })
  Any = Covenant.Type({ any: Covenant::Validator::Validator.any })
  
  Name = Covenant.Type({name: Covenant::Validator::Validation.coerce(:string)})
  Email = Covenant.Type({email: Covenant::Validator::Validation.coerce(:string)})
  # User = Covenant.Type({user: IdSchema & Name & Email})

  UserSchema = Covenant.Type(
    { user: IdSchema & Name & Email }
  )
end
# module MySchemas
#   IdSchema = Covenant.Schema :ID do
#     required(:id).filled(:string)
#   end

#   UserSchema = Covenant.Schema :User do
#     required(:name).filled(:string)
#     required(:email).filled(:string)
#   end

#   TokenSchema = Covenant.Schema(:Token) { required(:token).filled(:string) }
# end

module MyContracts
  include MySchemas

  GetTokenContract      = Covenant.Contract(:GetToken, IdSchema, TokenSchema)
  GetUserContract       = Covenant.Contract(:GetUser, TokenSchema, UserSchema)
  GetOwnerContract      = Covenant.Contract(:GetOwner, TokenSchema, UserSchema)
  AuthorizeUserContract = Covenant.Contract(:AuthorizeUser, IdSchema, Any)
  LogMessageContract    = Covenant.Contract(:LogMessage, Any, Any)
end

module MyTransformers
  include MySchemas
  
  GetUserIdFromUserTransformer = Covenant::Contracts::Transformer.new(UserSchema, IdSchema) do |user|
    user[:id]
  end
end