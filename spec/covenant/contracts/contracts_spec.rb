# frozen_string_literal: true

require_relative "../../support/dummy"

RSpec.describe Covenant::Contracts do
  it 'has a version number' do
    expect(Covenant::VERSION).not_to be_nil
  end
  let(:get_token_contract) {  MyContracts::GetTokenContract }
  let(:get_user_contract) {  MyContracts::GetUserContract }

  let(:runtime) do 
    Covenant.runtime.layer do |l|
      l.register(:GetToken, ->(input) { { token: "Token123" } })
      l.register(:GetUser, ->(input) { {  name:"Fede", email: "fede@gmail.com"  }})
    end
  end

  describe "Simple" do
    it 'run succeesfull contract' do
      expect(get_token_contract.command).to eq(:GetToken)
      expect(get_token_contract.input).to be_a(Covenant::Types::Struct)
      expect(get_token_contract.input.name).to eq(:id)
      expect(get_token_contract.output).to be_a(Covenant::Types::Struct)
      expect(get_token_contract.output.name).to eq(:token)

      result = runtime.call(get_token_contract, { id: '1' })
      
      expect(result).to be_a(Covenant::Runtime::ExecutionResult) 
      expect(result).to be_success
      expect(result.value.size).to eq(1)
      expect(result.value[:token].value).to eq("Token123")
    end

     it 'run failure contract' do
       wrong_runtime = Covenant.runtime.layer do |l|
        l.register(:GetToken, ->(input) { { token: "To" } })
        l.register(:GetUser, ->(input) { {  name:"Fede", email: "fede@gmail.com"  }})
      end
      
      expect(get_token_contract.command).to eq(:GetToken)
      expect(get_token_contract.input).to be_a(Covenant::Types::Struct)
      expect(get_token_contract.input.name).to eq(:id)
      expect(get_token_contract.output).to be_a(Covenant::Types::Struct)
      expect(get_token_contract.output.name).to eq(:token)

      result = wrong_runtime.call(get_token_contract, { id: '1' })
      
      expect(result).to be_a(Covenant::Runtime::ExecutionResult) 
      expect(result).to be_failure
      expect(result.value.size).to eq(1)
      expect(result.value[:token].value).to eq("To")
      expect(result.errors).to eq(["Length must be at least 4"])
      expect(result.blame.uncolorize).to match(/failed to validate output for GetToken with/)
    end
  end

  describe "Map" do
    it 'run a two contracts mapped' do
      contract = get_token_contract.map(get_user_contract)

      expect(contract).to be_a(Covenant::Contracts::Map)
      expect(contract.input).to be_a(Covenant::Types::Struct)
      expect(contract.input.name).to eq(:id)
      expect(contract.output).to be_a(Covenant::Types::Struct)
      expect(contract.output.name).to eq(:user)
      expect(contract.verify).to be_success

      Covenant::Ast::Ast.new(contract).to_ast.tap do |ast|
        expect(Covenant::Ast::AstThreePrinter.new(ast).print).not_to be nil
      end

      runtime.call(contract, { id: '1' }).tap do |result|
        expect(result).to be_a(Covenant::Runtime::ExecutionResult) 
        expect(result).to be_success
        expect(result.unwrap).to eq({ name:"Fede", email: "fede@gmail.com" })
      end
    end

    it "type mismatch" do 
      contract1 = get_user_contract.map(get_token_contract)
      contract2 = get_user_contract.map(get_token_contract)

      expect(contract1).to be_a(Covenant::Contracts::Map)
      expect(contract1.verify).to be_failure

      expect(contract2).to be_a(Covenant::Contracts::Map)
      expect(contract2.verify).to be_failure
    
      contract3 = contract2.map(contract1)
        .map(get_user_contract.timeout(1))
        .map(get_user_contract.retry(1))

      expect(contract3).to be_a(Covenant::Contracts::Map)
      expect(contract3.verify).to be_failure
      
      Covenant::Ast::Ast.new(contract2).to_ast.tap do |ast|
        expect(Covenant::Ast::AstShortPrinter.new(ast).print).not_to be nil
      end
    end
  end
end
