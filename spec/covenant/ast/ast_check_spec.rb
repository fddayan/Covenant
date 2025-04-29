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
  let(:authorize_user_contract) do
    Covenant.Contract(:AuthorizeUser, ID.struct, Covenant::Types::Void)
  end
  let(:log_message_contract) do
    Covenant.Contract(:LogMessage, Covenant::Types::Any,
                      Covenant::Types::Void)
  end
  let(:notify_success_contract) do
    Covenant.Contract(:NotifySuccess, Covenant::Types::Any, Covenant::Types::Void)
  end
  let(:notify_failure_contract) do
    Covenant.Contract(:NotifyFailure, Covenant::Types::Any, Covenant::Types::Void)
  end

  it 'check contract viollations' do
    ast = Covenant::Ast::Ast.new(get_user_contract.and_then(get_token_contract))
    res = Covenant::Ast::AstChecker.new(ast.to_ast).check

    expect(res).to be_a(Array)
    expect(res.first.to_s.uncolorize).to eq('map[(:token -> GetUser -> :user) -> (:id -> GetToken -> :token)] ! {:user=>"tag mismatch: expected :id got :user"}')
  end

  it 'throw exception on contract violation' do
    ast = Covenant::Ast::Ast.new(get_user_contract.and_then(get_token_contract))
    expect do
      Covenant::Ast::AstChecker.new(ast.to_ast).check!
    end.to raise_error(Covenant::ContractViolation, /tag mismatch/)
  end

  describe '#check_contract' do
    it 'when is enable it should validate contrat at runtime build' do
      expect(Covenant.check_contracts?).to be false

      Covenant.enable_check_contracts!

      expect do
        get_user_contract.and_then(get_token_contract)
      end.to raise_error(Covenant::ContractViolation, /tag mismatch/)

      expect(Covenant.check_contracts?).to be true

      Covenant.disable_check_contracts!
    end
  end
end
