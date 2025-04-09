RSpec.describe Covenant::Types::Prop do
  describe "with array" do
    it "should let me create a struct with an array" do 
       name = Covenant.Prop(:name, Covenant::Validator::Validation.coerce(:string))
       names = name.array

       result = names.call(["John Doe", "Jane Doe"])

       expect(result).to be_success
       expect(result.value).not_to be_empty
       expect(result.value).to be_kind_of(Array)
       expect(result.unwrap).to eq(["John Doe", "Jane Doe"])
    end
  end
end