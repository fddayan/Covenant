

RSpec.describe Covenant::Types::Scalar do
  describe "#call" do 
    it "should parse a value" do 
      id = Covenant.Scalar(:id, Covenant::Validator::Validation.coerce(:integer))

      result = id.call("1")
      expect(result).to be_success
      expect(result.value).to eq(1)
    end
  end

  describe "#==" do
    it "should compare two props" do
      id = Covenant.Scalar(:id, Covenant::Validator::Validation.coerce(:integer))
      id2 = Covenant.Scalar(:id, Covenant::Validator::Validation.coerce(:integer))

      expect(id).to eq(id2)
    end

    it "should not compare two different props" do
      id = Covenant.Scalar(:id, Covenant::Validator::Validation.coerce(:integer))
      name = Covenant.Scalar(:name, Covenant::Validator::Validation.coerce(:string))

      expect(id).not_to eq(name)
    end
  end

  describe "#+" do 
    it "should add two props" do
      id = Covenant.Scalar(:id, Covenant::Validator::Validation.coerce(:integer))
      name = Covenant.Scalar(:name, Covenant::Validator::Validation.coerce(:string))
      
      result = id + name

      expect(result).to be_a(Covenant::Types::Props)
      expect(result.props.size).to eq(2)
      expect(result.props).to all(be_a(Covenant::Types::Scalar))
      expect(result.props.map(&:tag)).to contain_exactly(:id, :name)
    end
  end

  describe "#-" do
    it "should remove a prop" do
      id = Covenant.Scalar(:id, Covenant::Validator::Validation.coerce(:integer))
      name = Covenant.Scalar(:name, Covenant::Validator::Validation.coerce(:string))
      
      result = id + name - name

      expect(result).to be_a(Covenant::Types::Props)
      expect(result.props.size).to eq(1)
      expect(result.props).to all(be_a(Covenant::Types::Scalar))
      expect(result.props.map(&:tag)).to contain_exactly(:id)
    end
    
  end
  
end
