# frozen_string_literal: true

require_relative "../../support/dummy"

RSpec.describe Covenant::Diff::SchemaDiff do
  it "should diff two schemas" do
    id = Covenant.Scalar(:id, Covenant::Validator::Validation.coerce(:integer))
    name = Covenant.Scalar(:name, Covenant::Validator::Validation.coerce(:string))
    age = Covenant.Scalar(:age, Covenant::Validator::Validation.coerce(:integer))

    schema1 = Covenant.Schema(:user, id + name)
    schema2 = Covenant.Schema(:user, id + name + age)

    result = Covenant::Diff::SchemaDiff.new(schema2, schema1).call

    expect(result).to be_a(Covenant::Diff::DiffResult)
    expect(result.success?).to be false
    expect(result.unwrap).to eq({ :user => { :age => "missing" }})
  end

   it "should diff two schemas with nested schemas" do
    id = Covenant.Scalar(:id, Covenant::Validator::Validation.coerce(:integer))
    name = Covenant.Scalar(:name, Covenant::Validator::Validation.coerce(:string))
    age = Covenant.Scalar(:age, Covenant::Validator::Validation.coerce(:integer))

    friend = Covenant.Schema(:friend, id + name)
    schema1 = Covenant.Schema(:user, id + name)
    schema2 = Covenant.Schema(:user, id + name + age + friend)

    result = Covenant::Diff::SchemaDiff.new(schema2, schema1).call

    expect(result).to be_a(Covenant::Diff::DiffResult)
    expect(result.success?).to be false
    expect(result.unwrap).to eq({ :user => { :age => "missing", :friend => "missing" }})
  end

   it "should diff two schemas with nested schemas and should nested schemas too" do
    id = Covenant.Scalar(:id, Covenant::Validator::Validation.coerce(:integer))
    name = Covenant.Scalar(:name, Covenant::Validator::Validation.coerce(:string))
    age = Covenant.Scalar(:age, Covenant::Validator::Validation.coerce(:integer))

    friend1 = Covenant.Schema(:friend, id + name)
    friend2 = Covenant.Schema(:friend, id + name + age)
    schema1 = Covenant.Schema(:user, id + name + friend1)
    schema2 = Covenant.Schema(:user, id + name + friend2 + age)

    result = Covenant::Diff::SchemaDiff.new(schema2, schema1).call

    expect(result).to be_a(Covenant::Diff::DiffResult)
    expect(result.success?).to be false
    expect(result.unwrap).to eq({ :user => { age: "missing", :friend =>  { age: "missing" }}})
  end
end