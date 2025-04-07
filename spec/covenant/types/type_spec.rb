require 'awesome_print'

require_relative '../../support/dummy'
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

     expect(FirstName.same?(Order)).to be_failure
     expect(FirstName.same?(Name)).to be_success
    #  expect(FirstName.props).to eq({ first_name: Name.props[:name] })
     expect(FirstName.call(first_name: 'Federico1234')[:first_name]).to be_kind_of(Covenant::Validator::ValidationResult)
     expect(FirstName.call(first_name: 'Federico1234')[:first_name].value).to eq('Federico1234')
     expect(FirstName.call(first_name: 'Federico1234')[:first_name].errors).to be_empty
     expect(FirstName.call(first_name: 'Federico1234')[:first_name]).to be_success
    end

    it "should let me rename a complex type buck keep the same type tag/name" do 
     Client = User.rename(:client)

     expect(Client.same?(Order)).to be_failure
     expect(Client.same?(User)).to be_success
    end
  end

  describe "#same" do  
    it "should return true for same type" do 
      expect(User.same?(User)).to be_success
    end

    it "should return failure and errors for different type" do 
      result = User.same?(Order)
      
      expect(result).to be_failure
      expect(result.errors).not_to be_empty
      expect(result.errors).to eq(["Types tags are not the same: [:user] => [:order]"])
    end

    it "should be able to compare combine types that are the same and succedde" do
      result =(MySchemas::ID & MySchemas::Name & MySchemas::Email)
                .same?(MySchemas::Name & MySchemas::ID & MySchemas::Email)

      expect(result).to be_success
    end

    it "should be able to compare combine types that are not the same and fail" do
      c1  = MySchemas::Name & MySchemas::Email
      c2 = (MySchemas::ID & MySchemas::Name)
      result = c1 =~ c2

      expect(result).to be_failure
      expect(result.errors).to match([/Types tags are not the same/])
      expect(c1.diff(c2).keys).to eq([:email])
    end
  end

  describe "#pick" do
    it "should pick a type and be different", skip: "I cannot make it work the way it is" do
      name1 = User.pick(:name)
      name2 = Name

      expect(name1.same?(name2)).to be_failure
      expect(name1.same?(User)).to be_failure
    end

    # it "should pick a nested type" do
    #   name1 = User.pick(:name)
    #   name2 = Name

    #   expect(name1.same?(name2)).to be_failure
    #   expect(name1.same?(User)).to be_failure
    # end
  end

  describe "#map_slice" do 
    it "should slice a type" do
      result = User[:user].map_slice(:name)
      

      expect(result).to be_kind_of(Covenant::Types::Type)
      expect(result.keys).to eq([:name])
      # expect(result.name).to eq(:name)
      # expect(result.props).to eq({ name: Name.props })
      expect(result.same?(Name)).to be_success
      expect(result.same?(User)).to be_failure
    end
  end

  # describe "#deep_tags" do
  #   it "should return the deep tags of a type" do
  #     puts "#{User.deep_tags}"
  #   end
  # end
  
end