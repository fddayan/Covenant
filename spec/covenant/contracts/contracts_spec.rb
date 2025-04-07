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
      l.register(:GetToken, ->(input) { { token:"Token123" } })
      l.register(:GetUser, ->(input) { { user: { name:"Fede", email: "fede@gmail.com" } }})
    end
  end

  describe "Simple" do 

    it 'run a single contract' do
      expect(get_token_contract.command).to eq(:GetToken)
      expect(get_token_contract.input).to be_a(Covenant::Types::Type)
      expect(get_token_contract.input.name).to eq(:id)
      expect(get_token_contract.output).to be_a(Covenant::Types::Type)
      expect(get_token_contract.output.name).to eq(:token)

      runtime.call(get_token_contract, { id: '1' }).tap do |result|
        expect(result).to be_a(Hash) 
        expect(result.size).to eq(1)
        expect(result[:token].value).to eq("Token123")
      end
    end
  end

  describe "Map" do
    it 'run a two contracts maped' do
      contract = get_token_contract.map(get_user_contract)

      expect(contract).to be_a(Covenant::Contracts::Map)
      expect(contract.input).to be_a(Covenant::Types::Type)
      expect(contract.input.name).to eq(:id)
      expect(contract.output).to be_a(Covenant::Types::Type)
      expect(contract.output.name).to eq(:user)
      expect(contract.verify).to be_success

      Covenant::Ast::Ast.new(contract).to_ast.tap do |ast|
        Covenant::Ast::AstThreePrinter.new(ast).print
      end

      runtime.call(contract, { id: '1' }).tap do |result|
        expect(result).to be_a(Hash) 

        # TODO: Improve this
        vals = result[:user].transform_values do |v|
          v.value
        end

        expect(vals).to eq({ name:"Fede", email: "fede@gmail.com" })
      end
    end

    it "type mismatch" do 
      contract1 = get_user_contract.map(get_token_contract)
      contract2 = get_user_contract.map(get_token_contract)

      expect(contract1).to be_a(Covenant::Contracts::Map)
      expect(contract1.verify).to be_failure

      # contract1.verify.tap do |result|
      #   expect(result).to be_a(Covenant::Schemas::SchemaComparatorResult)
      #   expect(result).to be_invalid
      # end

      expect(contract2).to be_a(Covenant::Contracts::Map)
      expect(contract2.verify).to be_failure
      # contract2.verify.tap do |result|
      #   expect(result).to be_a(Covenant::Schemas::SchemaComparatorResult)
      #   expect(result).to be_invalid
      # end

      # expect(contract1.verify).to be true

      contract3 = contract2.map(contract1)
        .map(get_user_contract.timeout(1))
        .map(get_user_contract.retry(1))

      expect(contract3).to be_a(Covenant::Contracts::Map)
      expect(contract3.verify).to be_failure
      # contract3.verify.tap do |result|
      #   expect(result).to be_a(Covenant::Schemas::SchemaComparatorResult)
      #   expect(result).to be_invalid
      # end
      
      Covenant::Ast::Ast.new(contract2).to_ast.tap do |ast|
        Covenant::Ast::AstShortPrinter.new(ast).print
      end
    end
  end
end
