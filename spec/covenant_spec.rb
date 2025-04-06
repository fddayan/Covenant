# frozen_string_literal: true

require_relative "./support/dummy"

RSpec.describe Covenant do
  it 'has a version number' do
    expect(Covenant::VERSION).not_to be_nil
  end
  let(:get_token_contract) {  MyContracts::GetTokenContract }
  let(:get_user_contract) {  MyContracts::GetUserContract }

  let(:runtime) do 
    Covenant.runtime.layer do |l|
      l.register(:GetToken, ->(input) { { token:"Token123" } })
      l.register(:GetUser, ->(input) { { name:"Fede", email: "fede@gmail.com" } })
    end
  end

  describe "Simple" do 

    it 'run a single contract' do
      expect(get_token_contract.command).to eq(:GetToken)
      expect(get_token_contract.input).to be_a(Covenant::Schemas::Schema)
      expect(get_token_contract.input.name).to eq(:ID)
      expect(get_token_contract.output).to be_a(Covenant::Schemas::Schema)
      expect(get_token_contract.output.name).to eq(:Token)

      runtime.call(get_token_contract, { id: '1' }).tap do |result|
        expect(result).to be_a(Hash) 
        expect(result).to eq({ token:"Token123"})
      end
    end
  end

  describe "Map" do
    it 'run a tow contracts maped' do
      contract = get_token_contract.map(get_user_contract)

      expect(contract).to be_a(Covenant::Contracts::Map)
      expect(contract.input).to be_a(Covenant::Schemas::Schema)
      expect(contract.input.name).to eq(:ID)
      expect(contract.output).to be_a(Covenant::Schemas::Schema)
      expect(contract.output.name).to eq(:User)
      expect(contract.verify).to be_valid

      Covenant::Ast::Ast.new(contract).to_ast.tap do |ast|
        Covenant::Ast::AstThreePrinter.new(ast).print
      end

      runtime.call(contract, { id: '1' }).tap do |result|
        expect(result).to be_a(Hash) 
        expect(result).to eq({ name:"Fede", email: "fede@gmail.com" })
      end
    end

    it "type mismatch" do 
      contract1 = get_user_contract.map(get_token_contract)
      contract2 = get_user_contract.map(get_token_contract)

      expect(contract1).to be_a(Covenant::Contracts::Map)
      contract1.verify.tap do |result|
        expect(result).to be_a(Covenant::Schemas::SchemaComparatorResult)
        expect(result).to be_invalid
      end

      expect(contract2).to be_a(Covenant::Contracts::Map)
      contract2.verify.tap do |result|
        expect(result).to be_a(Covenant::Schemas::SchemaComparatorResult)
        expect(result).to be_invalid
      end

      # expect(contract1.verify).to be true

      contract3 = contract2.map(contract1)
        .map(get_user_contract.timeout(1))
        .map(get_user_contract.retry(1))

      expect(contract3).to be_a(Covenant::Contracts::Map)
      contract3.verify.tap do |result|
        expect(result).to be_a(Covenant::Schemas::SchemaComparatorResult)
        expect(result).to be_invalid
      end
      
      Covenant::Ast::Ast.new(contract2).to_ast.tap do |ast|
        Covenant::Ast::AstShortPrinter.new(ast).print
      end
    end
  end
end
