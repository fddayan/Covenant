# module MySchemas
#   ID = Covenant.Type({ id: Covenant::Validator::Validation.coerce(:integer) })
#   Token = Covenant.Type({ token: Covenant::Validator::Validation.coerce(:string) })
#   Any = Covenant.Type({ any: Covenant::Validator::Validator.any })
  
#   Name = Covenant.Type({ name: Covenant::Validator::Validation.coerce(:string)})
#   Email = Covenant.Type({ email: Covenant::Validator::Validation.coerce(:string)})

#   User = Covenant.Type(
#     { user: ID & Name & Email }
#   )

#   ID = Covenant.Type({ id: Covenant::Validator::Validation.coerce(:integer), fede: Covenant::Validator::Validation.coerce(:string) })
# end

module MyProps
  ID    = Covenant.Prop(:id, Covenant.Validate.coerce(:integer))
  Token = Covenant.Prop(:token, Covenant.Validate.coerce(:string).and_then(Covenant.Validate.length(min: 4)))
  Name  = Covenant.Prop(:name, Covenant.Validate.coerce(:string))
  Email = Covenant.Prop(:email, Covenant.Validate.coerce(:string))
end

module MySchemas
  include MyProps
  Any = Covenant.Prop(:any, Covenant::Validator::Validator.any)
  User = Covenant.Struct(:user, ID + Name + Email)
end

module MyContracts
  include MySchemas

  GetTokenContract      = Covenant.Contract(:GetToken, ID.struct, Token.struct)
  GetUserContract       = Covenant.Contract(:GetUser, Token.struct, User)
  GetOwnerContract      = Covenant.Contract(:GetOwner, Token.struct, User)
  AuthorizeUserContract = Covenant.Contract(:AuthorizeUser, ID.struct, Any)
  LogMessageContract    = Covenant.Contract(:LogMessage, Any, Any)
end

module MyTransformers
  include MySchemas
  
  GetUserIdFromUserTransformer = Covenant::Contracts::Transformer.new(User, ID) do |user|
    user[:id]
  end
end