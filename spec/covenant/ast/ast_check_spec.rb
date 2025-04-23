ID    = Covenant.Scalar(:id, Covenant.Validate.coerce(:integer))
Token = Covenant.Scalar(:token,
                        Covenant.Validate.coerce(:string)
                        .and_then(Covenant.Validate.length(min: 4)))
Name  = Covenant.Scalar(:name, Covenant.Validate.coerce(:string))
Email = Covenant.Scalar(:email, Covenant.Validate.coerce(:string))
User = Covenant.Schema(:user, ID + Name + Email)

RSpec.describe Covenant::Ast::Ast do
  let(:get_token_contract) { Covenant.Contract(:GetToken, ID.struct, Token.struct) }
  let(:get_user_contract) { Covenant.Contract(:GetUser, Token.struct, User) }
  let(:get_owner_contract) { Covenant.Contract(:GetOwner, Token.struct, User) }
  let(:authorize_user_contract) { Covenant.Contract(:AuthorizeUser, ID.struct, Covenant::Types::Void) }
  let(:log_message_contract) { Covenant.Contract(:LogMessage, Covenant::Types::Any, Covenant::Types::Void) }
  let(:notify_success_contract) { Covenant.Contract(:NotifySuccess, Covenant::Types::Any, Covenant::Types::Void) }
  let(:notify_failure_contract) { Covenant.Contract(:NotifyFailure, Covenant::Types::Any, Covenant::Types::Void) }

  it "check contract viollations" do
    ast = Covenant::Ast::Ast.new(get_user_contract.and_then(get_token_contract))
    res = Covenant::Ast::AstChecker.new(ast.to_ast).check

    expect(res).to be_a(Array)
    expect(res.first.to_s.uncolorize).to eq('map[(:token -> GetUser -> :user) -> (:id -> GetToken -> :token)] ! {:user=>"tag mismatch: expected :user got :id"}')
  end
end