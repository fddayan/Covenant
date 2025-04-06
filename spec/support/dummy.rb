module Primitives
  # Id = Dry::Types['strict.string']
  # Token = Dry::Types['strict.string']
  # Void = Dry::Types['strict.nil']
  # Any = Dry::Types['any']
  # String = Dry::Types['strict.string']
  # Integer = Dry::Types['strict.integer']
  # Float = Dry::Types['strict.float']
  # Bool = Dry::Types['strict.bool']
  # Array = Dry::Types['array']
  # Hash = Dry::Types['hash']
  # Symbol = Dry::Types['symbol']
  # Date = Dry::Types['date']
  # DateTime = Dry::Types['date_time']
  # Time = Dry::Types['time']
  # Regexp = Dry::Types['regexp']
  # Email = Dry::Types['string.email']
  # Url = Dry::Types['string.url']
  # Uuid = Dry::Types['string.uuid']
  # Enum = Dry::Types['string.enum']
  # EnumInt = Dry::Types['integer.enum']
  # EnumSymbol = Dry::Types['symbol.enum']

  Void = Covenant.Schema(:Void) { optional(:void) }
  Any = Covenant.Schema(:Any) { optional(:any) }
  String = Covenant.Schema(:String) { optional(:value).filled(:string) }
end

module MySchemas
  IdSchema = Covenant.Schema :ID do
    required(:id).filled(:string)
  end

  UserSchema = Covenant.Schema :User do
    required(:name).filled(:string)
    required(:email).filled(:string)
  end

  TokenSchema = Covenant.Schema(:Token) { required(:token).filled(:string) }
end

module MyContracts
  include MySchemas

  GetTokenContract      = Covenant.Contract(:GetToken, IdSchema, TokenSchema)
  GetUserContract       = Covenant.Contract(:GetUser, TokenSchema, UserSchema)
  GetOwnerContract      = Covenant.Contract(:GetOwner, TokenSchema, UserSchema)
  AuthorizeUserContract = Covenant.Contract(:AuthorizeUser, IdSchema, Primitives::Void)
  LogMessageContract    = Covenant.Contract(:LogMessage, Primitives::Any, Primitives::Void)
end

module MyTransformers
  include MySchemas
  
  GetUserIdFromUserTransformer = Covenant::Contracts::Transformer.new(UserSchema, IdSchema) do |user|
    user[:id]
  end
end