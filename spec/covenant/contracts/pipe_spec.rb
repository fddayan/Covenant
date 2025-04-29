# frozen_string_literal: true
require_relative '../../support/dummy'

RSpec.describe Covenant::Contracts::Pipe do
  let(:runtime) do
    Covenant.runtime.layer do |l|
      l.register(:GetToken, ->(input) { { token: 'Token123' } })
      l.register(:GetUser, ->(input) { { id: 1,  name: 'Fede', email: 'fede@gmail.com' } })
      l.register(:LogMessage, ->(input) { puts "Log: #{input}"; nil })
    end
  end

  describe "#build" do
    it 'builds a contract chain' do
      contract1 = MyContracts::GetTokenContract
      contract2 = MyContracts::GetUserContract

      pipe = described_class.new([contract1, contract2])
      contracts = pipe.build

      expect(contracts).to be_a(Covenant::Contracts::Map)
      
      result = runtime.call(contracts, { id: '1' })

      expect(result).to be_a(Covenant::Runtime::ExecutionResult)
      expect(result).to be_success
      expect(result.unwrap).to eq({ :id => 1, :name => "Fede", :email => "fede@gmail.com" })
      expect(result.value).to include(:id, :name, :email)
    end

    it "build contract chain with compositions (tee)" do
      contract1 = MyContracts::GetTokenContract
      contract2 = MyContracts::GetUserContract
      contract3 = MyContracts::LogMessageContract

      pipe = described_class.new(
        [
          contract1, 
          contract2,
          ->(prev) { prev.tee(contract3) } 
        ]
      )
      contracts = pipe.build

      expect(contracts).to be_a(Covenant::Contracts::Map)

      result = runtime.call(contracts, { id: '1' })

      expect(result).to be_a(Covenant::Runtime::ExecutionResult)
      expect(result).to be_success
      expect(result.unwrap).to eq({ :id => 1, :name => "Fede", :email => "fede@gmail.com" })
      expect(result.value).to include(:id, :name, :email)
    end

    it "build contract chain using DSL" do
      contract1 = MyContracts::GetTokenContract
      contract2 = MyContracts::GetUserContract
      contract3 = MyContracts::LogMessageContract
      
      contracts = Covenant::Contracts.pipe(contract1, contract2, Covenant::Contracts.tee(contract3))

      expect(contracts).to be_a(Covenant::Contracts::Map)

      result = runtime.call(contracts, { id: '1' })

      expect(result).to be_a(Covenant::Runtime::ExecutionResult)
      expect(result).to be_success
      expect(result.unwrap).to eq({ :id => 1, :name => "Fede", :email => "fede@gmail.com" })
      expect(result.value).to include(:id, :name, :email)
    end
  end
end