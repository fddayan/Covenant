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
  ID    = Covenant.Scalar(:id, Covenant.Validate.coerce(:integer))
  Token = Covenant.Scalar(:token, 
    Covenant.Validate
    .coerce(:string)
    .and_then(Covenant.Validate.length(min: 4)))
  Name  = Covenant.Scalar(:name, Covenant.Validate.coerce(:string))
  Email = Covenant.Scalar(:email, Covenant.Validate.coerce(:string))
end

module MySchemas
  include MyProps
  Any = Covenant.Scalar(:any, Covenant::Validator::Validator.any)
  User = Covenant.Schema(:user, ID + Name + Email)
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