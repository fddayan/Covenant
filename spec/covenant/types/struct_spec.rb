RSpec.describe Covenant::Types::Struct do
  describe "#call" do 
    it "should parse a valid value and succeed" do 
      id = Covenant.Prop(:id, Covenant::Validator::Validation.coerce(:integer))
      name = Covenant.Prop(:name, Covenant::Validator::Validation.coerce(:string))

      struct = Covenant.Struct(:user, id + name)

      result = struct.call({ id: "1", name: "John Doe" })
      expect(result).to be_success
      expect(result.value[:id]).to be_success
      expect(result.value[:name]).to be_success
      expect(result.unwrap).to eq({ id: 1, name: "John Doe" })
    end

    it "should parse an invalid value and fail" do 
      id = Covenant.Prop(:id, Covenant::Validator::Validation.coerce(:integer))
      name = Covenant.Prop(:name, Covenant::Validator::Validation.coerce(:string).and_then(Covenant::Validator::Validation.length(min: 5, max: 8)))

      user = Covenant.Struct(:user, id + name)

      result = user.call({ id: "1", name: "Jo" })

      expect(result).to be_failure
      expect(result.value[:name]).to be_failure
      expect(result.value[:name].errors).not_to be_empty
      expect(result.unwrap).to eq({ id: 1, name: "Jo" })
    end

    it "should let me use a struct with a struct" do 
      id = Covenant.Prop(:id, Covenant::Validator::Validation.coerce(:integer))
      name = Covenant.Prop(:name, Covenant::Validator::Validation.coerce(:string))
      price = Covenant.Prop(:price, Covenant::Validator::Validation.coerce(:float))
      
      user = Covenant.Struct(:user, id + name)
      order = Covenant.Struct(:order, id + user + price)

      expect(order.prop?(:id)).to be true
      expect(order.prop?(:user)).to be true
      expect(order.prop?(:price)).to be true

      result = order.call({ 
        id: "1", 
        user: {  id: "1", name: "John Doe" },
        price: "10.0" 
      })

      expect(result).to be_success
      expect(result.value[:id]).to be_success
      expect(result.value[:user]).to be_success
      expect(result.value[:user].value[:id]).to be_success
      expect(result.value[:user].value[:name]).to be_success
      expect(result.value[:price]).to be_success
      expect(result.unwrap).to eq({
        id: 1,
        user: { id: 1, name: "John Doe" },
        price: 10.0
      })
    end
  end
end