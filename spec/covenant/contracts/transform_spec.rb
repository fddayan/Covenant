# frozen_string_literal: true

require_relative "../../support/dummy"

RSpec.describe Covenant::Contracts::Transformer do
  let(:get_token_contract) {  MyContracts::GetTokenContract }
  let(:get_user_contract) {  MyContracts::GetUserContract }

  let(:runtime) do 
    Covenant.runtime.layer do |l|
      l.register(:GetToken, ->(input) { { token: "Token123" } })
      l.register(:GetUser, ->(input) { { id: 1,  name:"Fede", email: "fede@gmail.com"  }})
    end
  end

  it "should let me transform a value to make it fit into a contract" do
    contract =  get_token_contract
                .map(get_user_contract)
                .transform(MySchemas::User, MyProps::ID.struct) { |user| { id: user[:id].to_s } }
                .map(get_token_contract)

    result = runtime.call(contract, { id: '1' })

    expect(result).to be_a(Covenant::Runtime::ExecutionResult)

    expect(result).to be_success
    expect(result.value).to be_a(Hash)
    expect(result.value.size).to eq(1)
    expect(result.value[:token]).to be_a(Covenant::Validator::ValidationResult)
    expect(result.value[:token].value).to eq("Token123")
    expect(result.unwrap).to eq({ token: "Token123"})
  end
end