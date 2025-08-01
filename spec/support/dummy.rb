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
  AuthorizeUserContract = Covenant.Contract(:AuthorizeUser, ID.struct, Any.struct)
  LogMessageContract    = Covenant.Contract(:LogMessage, Any.struct, Any.struct)
  MetricMessageContract = Covenant.Contract(:MetricMessage, Any.struct, Any.struct)

  VerifyUserContract   = AuthorizeUserContract.and_then(MetricMessageContract)

  NotifySuccessContract = Covenant.Contract(:NotifySuccess,
                                              Covenant::Types::Any,
                                              Covenant::Types::Void)
  NotifyFailureContract = Covenant.Contract(:NotifyFailure,
                                            Covenant::Types::Any,
                                            Covenant::Types::Void)

  HasBalance = Covenant.Contract(:HasBalance, User, Covenant::Types::Bool)

  ChargeUserContract = Covenant.Contract(:ChargeUser, User, Covenant::Types::Void)

  HasMinBalance = Covenant.Contract(:HasMinBalance, User, Covenant::Types::Bool)

  NotifyNoBalanceContract = Covenant.Contract(:NotifyNoBalance, User, Covenant::Types::Void)

  GetUserById = GetTokenContract
              .and_then(GetUserContract)
              .tee(VerifyUserContract)
              .tee(LogMessageContract)
              # .tee(
              #   Covenant::Contracts.match(
              #     success: NotifySuccessContract,
              #     failure: NotifyFailureContract
              #   )
              # )
end

module MyTransformers
  include MySchemas
  
  # GetUserIdFromUserTransformer = Covenant::Contracts::Transformer.new(User, ID) do |user|
  #   user[:id]
  # end
end