require 'awesome_print'

require_relative '../../support/types_dummy'


RSpec.describe Covenant::Types::Type do
  describe '#call' do
    it "should work wth one type pasing integer" do 
      result = ID.call(id: "1")

      expect(result[:id]).to be_success
      expect(result[:id].value).to eq(1)
      expect(result[:id]).to be_kind_of(Covenant::Validator::ValidationResult)
    end
    
    it "should work with one type passing string" do
      result = Name.call(name: 'Federico1234')

      expect(result[:name]).to be_success
      expect(result[:name].value).to eq("Federico1234")
      expect(result[:name]).to be_kind_of(Covenant::Validator::ValidationResult)
    end

    it "should work with one type passing struct" do
      result = User.call(user: { id: 1, name: 'Federico1234', email: 'Fedde' })

      expect(result[:user]).not_to be_nil
      expect(result[:user][:id]).to be_success
      expect(result[:user][:id].value).to eq(1)
      expect(result[:user][:name]).to be_success
      expect(result[:user][:name].value).to eq("Federico1234")
      expect(result[:user][:email]).to be_success
      expect(result[:user][:email].value).to eq("Fedde")
      expect(result[:user]).to be_kind_of(Hash)
      expect(result[:user][:id]).to be_kind_of(Covenant::Validator::ValidationResult)
      expect(result[:user][:name]).to be_kind_of(Covenant::Validator::ValidationResult)
      expect(result[:user][:email]).to be_kind_of(Covenant::Validator::ValidationResult)
    end

    it "should return failure with one type passing wrong value" do
      result = Name.call(name: 'Fede')

      expect(result[:name]).to be_failure
      expect(result[:name].value).to eq("Fede")
      expect(result[:name].errors).not_to be_empty
    end

    it "should work with a complext nested excturcture" do 
      result = Order.call(
        {
          order: {
            id: 1,
            user: {
              id: 1,
              name: 'Federico1234',
              email: 'Fedde'
            },
            order_items: [
              {
                id: 1,
                product: {
                  id: 1, name: 'Federico1234', price: 10.0
                },
                price: 10.0
              }
            ]
          }
        }
      )

      expect(result).to be_kind_of(Hash)
      expect(result.dig(:order, :id)).to be_success
      expect(result.dig(:order, :user, :id)).to be_success
      expect(result.dig(:order, :order_items)).to be_kind_of(Array)
    end

    it "should work with array typs" do 
      result = Names.call(names: ['Fede', 'Federico1235'])

      expect(result).to be_kind_of(Hash)
      expect(result[:names]).to be_kind_of(Array)

      expect(result[:names].first).to be_kind_of(Covenant::Validator::ValidationResult)
      expect(result[:names].first).to be_failure
      expect(result[:names].first.value).to eq('Fede')
      expect(result[:names].first.errors).not_to be_empty
      
      expect(result[:names].last).to be_kind_of(Covenant::Validator::ValidationResult)
      expect(result[:names].last).to be_success
      expect(result[:names].last.value).to eq('Federico1235')
      expect(result[:names].last.errors).to be_empty
    end

    it "should let me rename a type buck keep the same type tag/name" do 
     FirstName =  Name.rename(:first_name)

     expect(FirstName.same?(Order)).to be false
     expect(FirstName.same?(Name)).to be true
    #  expect(FirstName.props).to eq({ first_name: Name.props[:name] })
     expect(FirstName.call(first_name: 'Federico1234')[:first_name]).to be_kind_of(Covenant::Validator::ValidationResult)
     expect(FirstName.call(first_name: 'Federico1234')[:first_name].value).to eq('Federico1234')
     expect(FirstName.call(first_name: 'Federico1234')[:first_name].errors).to be_empty
     expect(FirstName.call(first_name: 'Federico1234')[:first_name]).to be_success
    end

    it "should let me rename a complex type buck keep the same type tag/name" do 
     Client = User.rename(:client)

     expect(Client.same?(Order)).to be false
     expect(Client.same?(User)).to be true
    end

    it "should match other type" do 
      # result = ID.call(id: 1)
      # expect(result.match?(ID)).to be true
      # expect(result.match?(Name)).to be false
    end

    # it "should run a function" do
    #   GetUserById = Covenant.Func(:get_user_by_id, ID, User)

    #   layer = Ceventant.layer.tap do |l|
    #     l.register(:get_user_by_id) do |id|
    #       { id: id, name: 'Federico1234', email: 'Fedde' }
    #     end
    #   end

    #   result = Ceventant.run(layer, GetUserById.new(id: 1))

    #   expect(result).to be_success
    #   expect(result.value).not_to be_nil
    # end
  end
end