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

  describe "#==" do
    it "should compare two structs with the same values" do 
      id = Covenant.Prop(:id, Covenant::Validator::Validation.coerce(:integer))
      name = Covenant.Prop(:name, Covenant::Validator::Validation.coerce(:string))

      struct1 = Covenant.Struct(:user, id + name)
      struct2 = Covenant.Struct(:user, id + name)

      expect(struct1 == struct2).to be true
    end

    it "should compare two structs with different values" do 
      id = Covenant.Prop(:id, Covenant::Validator::Validation.coerce(:integer))
      name = Covenant.Prop(:name, Covenant::Validator::Validation.coerce(:string))

      struct1 = Covenant.Struct(:user, id + name)
      struct2 = Covenant.Struct(:user, id + name + Covenant.Prop(:age, Covenant::Validator::Validation.coerce(:integer)))

      expect(struct2 == struct1).to be false
    end
  end

  describe "#compare" do
    it "should compare two structs with the same values" do
      id = Covenant.Prop(:id, Covenant::Validator::Validation.coerce(:integer))
      name = Covenant.Prop(:name, Covenant::Validator::Validation.coerce(:string))

      struct1 = Covenant.Struct(:user, id + name)
      struct2 = Covenant.Struct(:user, id + name + Covenant.Prop(:age, Covenant::Validator::Validation.coerce(:integer)))

      result = struct2.compare(struct1)

      expect(result).to be_kind_of(Covenant::Comparable::Result)
      expect(result.success?).to be false
      expect(result.errors).not_to be_empty
      expect(result.unwrap).to eq(user: [{:id=>[]}, {:name=>[]}, {:age=>["missing prop"]}])
    end

    it "should compare nested structs" do
      id = Covenant.Prop(:id, Covenant::Validator::Validation.coerce(:integer))
      name = Covenant.Prop(:name, Covenant::Validator::Validation.coerce(:string))
      price = Covenant.Prop(:price, Covenant::Validator::Validation.coerce(:float))
      user = Covenant.Struct(:user, id + name)
      order = Covenant.Struct(:order, id + user + price)
      order2 = Covenant.Struct(:order, id + user + price)
      result = order.compare(order2)

      expect(result.success?).to be true
      expect(result.failure?).to be false
      expect(result.unwrap).to eq({:order=>[{:id=>[]}, {:user=>[{:id=>[]}, {:name=>[]}]}, {:price=>[]}]})
    end
    
    it "should compare nested structs with different values and fail" do
      id = Covenant.Prop(:id, Covenant::Validator::Validation.coerce(:integer))
      name = Covenant.Prop(:name, Covenant::Validator::Validation.coerce(:string))
      price = Covenant.Prop(:price, Covenant::Validator::Validation.coerce(:float))
      
      user1 = Covenant.Struct(:user, id + name + Covenant.Prop(:age, Covenant::Validator::Validation.coerce(:integer)))
      user2 = Covenant.Struct(:user, id + name)
      
      order = Covenant.Struct(:order, id + user1 + price)
      order2 = Covenant.Struct(:order, id + user2 + price)
      
      result = order.compare(order2)

      expect(result.success?).to be false
      expect(result.failure?).to be true
      expect(result.unwrap).to eq(:order => [{:id=>[]}, {:user=>[{:id=>[]}, {:name=>[]}, {:age=>["missing prop"]}]}, {:price=>[]}])
    end

    it "should compare nested structs with different values and tags and fail" do
      id = Covenant.Prop(:id, Covenant::Validator::Validation.coerce(:integer))
      name = Covenant.Prop(:name, Covenant::Validator::Validation.coerce(:string))
      price = Covenant.Prop(:price, Covenant::Validator::Validation.coerce(:float))
      
      user = Covenant.Struct(:user, id + name)
      order = Covenant.Struct(:order, id + user + price)
      order2 = Covenant.Struct(:order2, id + user + price + Covenant.Prop(:age, Covenant::Validator::Validation.coerce(:integer)))
      
      result = order2.compare(order)

      expect(result.success?).to be false
      expect(result.failure?).to be true
      expect(result.errors).not_to be_empty
    end
  end

  describe "#pick" do
    it "should pick a prop from the struct" do
      id = Covenant.Prop(:id, Covenant::Validator::Validation.coerce(:integer))
      name = Covenant.Prop(:name, Covenant::Validator::Validation.coerce(:string))

      struct = Covenant.Struct(:user, id + name)

      expect(struct.pick(:id)).to be_kind_of(Covenant::Types::Props)
      expect(struct.pick(:name)).to be_kind_of(Covenant::Types::Props)
      expect(struct.pick(:age)).to be_empty

      expect(struct.pick(:id) == id).to be false
      expect(struct.pick(:name) == name).to be false

      expect(id == id).to be true
      expect(name == name).to be true
    end

    it "should pick a prop from a nested struct" do
      id = Covenant.Prop(:id, Covenant::Validator::Validation.coerce(:integer))
      name = Covenant.Prop(:name, Covenant::Validator::Validation.coerce(:string))
      price = Covenant.Prop(:price, Covenant::Validator::Validation.coerce(:float))
      
      user = Covenant.Struct(:user, id + name)
      order = Covenant.Struct(:order, id + user + price)

      expect(order.pick(:user)).to be_kind_of(Covenant::Types::Props)
      expect(order.pick(:user).pick(:name)).to be_kind_of(Covenant::Types::Props)
      expect(order.pick(:user).pick(:age)).to be_empty

      expect(order.pick(:user).tag_chain).to eq([[:user], [:id, :user, :price], :order])
      expect(order.pick(:user)[:user].tag_chain).to eq([[:id, :name], :user])

      expect(order.pick(:user)[:user].pick(:name).tag_chain).to eq([[:name], [:id, :name], :user])

      expect(order.pick(:user)[:user].pick(:name) == order.pick(:user)[:user].pick(:name)).to be true
      expect(order.pick(:user)[:user].pick(:name) == order.pick(:user)[:user].pick(:id)).to be false
      expect(order.pick(:user)[:user].pick(:name) == name).to be false
    end
  end

  describe "#omit" do
    it "should omit a prop from the struct" do
      id = Covenant.Prop(:id, Covenant::Validator::Validation.coerce(:integer))
      name = Covenant.Prop(:name, Covenant::Validator::Validation.coerce(:string))

      struct = Covenant.Struct(:user, id + name)

      expect(struct.omit(:id)).to be_kind_of(Covenant::Types::Struct)
      expect(struct.omit(:name)).to be_kind_of(Covenant::Types::Struct)
      expect(struct.omit(:age)).not_to be_empty

      new_struct = struct.omit(:id)
      expect(new_struct.tag?(:name)).to be true
      expect(new_struct.tag?(:id)).to be false

      expect(struct.omit(:id) == id).to be false
      expect(struct.omit(:name) == name).to be false

      expect(id == id).to be true
      expect(name == name).to be true
    end

    it "should omit a prop from a nested struct" do
      id = Covenant.Prop(:id, Covenant::Validator::Validation.coerce(:integer))
      name = Covenant.Prop(:name, Covenant::Validator::Validation.coerce(:string))
      price = Covenant.Prop(:price, Covenant::Validator::Validation.coerce(:float))
      
      user = Covenant.Struct(:user, id + name)
      order = Covenant.Struct(:order, id + user + price)

      expect(order.omit(:user)).to be_kind_of(Covenant::Types::Struct)
      expect(order.omit(:user).omit(:name)).to be_kind_of(Covenant::Types::Struct)
      expect(order.omit(:user).omit(:age)).not_to be_empty
      expect(order.omit(:user).tag_chain).to eq([[:id, :price],:order])
    end
  end
  

  describe "with an array" do
    it "should let me use a struct with an array" do
      name = Covenant.Prop(:name, Covenant::Validator::Validation.coerce(:string))
      names = name.array
      user = Covenant.Struct(:user, names.to_props)

      result = user.call({ name_array: ["John Doe", "Jane Doe"] })

      expect(result).to be_success
      expect(result.value[:name_array]).to be_success
      expect(result.unwrap).to eq({ name_array: ["John Doe", "Jane Doe"] })
    end
  end
  
end