# frozen_string_literal: true

# require_relative '../../support/dummy'

RSpec.describe Covenant::Contracts::IContract do
  let(:int_type) { Covenant.Scalar(:number, Covenant.Validate.coerce(:integer)) }
  let(:string_type) { Covenant.Scalar(:text, Covenant.Validate.coerce(:string)) }
  let(:command_registry) do
    Covenant.runtime.layer do |l|
      l.register(:double, ->(input) { input * 2 })
      l.register(:stringify, ->(input) { input.to_s })
      l.register(:add_one, ->(input) { input + 1 })
      l.register(:add_prefix, ->(input) { "Prefix: #{input}" })
    end.command_registry
  end

 describe "with schema and simple contract" do 
    let(:user_schema) {  Covenant.Schema(:User, id: int_type, name: string_type, email: string_type) }
    let(:post_schema) {  Covenant.Schema(:Post,  title: string_type, body: string_type) }
    let(:create_post_payload) { Covenant.Schema(:CreatePostPayload, user: user_schema, post: post_schema) }
    let(:create_post_contract) { Covenant::Contracts::SimpleContract.new(:create_post_contract, create_post_payload, post_schema) }
  
    it "initializes with valid input and output types" do
      expect(create_post_contract.input.tag).to eq(create_post_payload.tag)
      expect(create_post_contract.output.tag).to eq(post_schema.tag)
    end

    it "runs successfully with valid input" do
      input = { user: { id: 1, name: 'Fede', email: 'fede@example.com' }, post: { title: 'Hello World', body: 'This is a test post.' } }
      
      layer = Covenant::Container::CommandLayer.new
      layer << create_post_contract.of{ |input| { title: input[:post][:title], body: input[:post][:body] } }

      create_post_contract_with_requirements = layer.provide(create_post_contract)

      result = create_post_contract_with_requirements.call(input) 
      expect(result).to be_a(Covenant::Validator::ValidationResult)
    end

  end

  describe 'SimpleContract' do
    let(:simple_contract) do
      Covenant::Contracts::SimpleContract.new(:double, int_type, int_type)
    end

    it 'initializes with command, input, and output' do
      expect(simple_contract.input).to eq(int_type)
      expect(simple_contract.output).to eq(int_type)
      expect(simple_contract.requirements).to eq([:double])
    end

    it 'raises error for non-symbol command' do
      expect do
        Covenant::Contracts::SimpleContract.new('double', int_type, int_type)
      end.to raise_error(ArgumentError, /Expected type Symbol/)
    end

    it 'calls the appropriate handler' do
      handlers = ->(x) { x * 2 }
      layer = Covenant::Container::CommandLayer.new
      layer << simple_contract.of(&handlers)

      result = layer.provide(simple_contract).call(5)

      expect(result.unwrap).to eq(10)
    end
  end

  describe 'ContractRunner' do
    let(:runner) { Covenant::Contracts::ContractRunner.new(command_registry) }
    let(:simple_contract) do
      Covenant::Contracts::SimpleContract.new(:double, int_type, int_type)
    end
    let(:double_contract) do
      Covenant::Contracts::SimpleContract.new(:double, int_type, int_type)
    end
    let(:stringify_contract) do
      Covenant::Contracts::SimpleContract.new(:stringify, int_type, string_type)
    end
    let(:add_one_contract) do
      Covenant::Contracts::SimpleContract.new(:add_one, int_type, int_type)
    end

    it 'initializes with command registry' do
      expect(runner).to be_a(Covenant::Contracts::ContractRunner)
    end

    describe '#call' do
      let(:complex_contract) do
        Covenant::Contracts::ComposableContract.new(:complex_contract, { int_type => string_type }, [double_contract, stringify_contract, add_one_contract]) do |handlers, args|
          Covenant::Handlers.pipe(
             handlers.fetch(:double),
             handlers.fetch(:add_one),
             handlers.fetch(:stringify)
            ).call(args)
        end
      end

      let(:add_prefix_contract) do
        Covenant::Contracts::SimpleContract.new(:add_prefix, string_type, string_type)
      end

      let(:complex_contract2) do
        Covenant::Contracts::ComposableContract.new(:complex_contract2, { int_type => string_type }, [complex_contract, add_prefix_contract]) do |handlers, args|
          Covenant::Handlers.pipe(
            handlers.fetch(:complex_contract),
            handlers.fetch(:add_prefix),
          ).call(args)
        end
      end
      it 'raises error for unsupported contract type' do
        unsupported = double('UnsupportedContract')
        expect do
          runner.call(unsupported, {})
        end.to raise_error(ArgumentError, /Unsupported contract type/)
      end

      it "run ComplexContract success" do
        expect(complex_contract.requirements).to include(:double, :stringify, :add_one)

        layer =  Covenant::Container::CommandLayer.new

        layer << double_contract.of { |input| input * 2 }
        layer << stringify_contract.of { |input| input.to_s }
        layer << add_one_contract.of { |input| input + 1 }
        layer << add_prefix_contract.of { |input| "Prefix: #{input}" }

        complex_contract_with_requirments = layer.provide(complex_contract)

        expect(complex_contract_with_requirments.requirements_provided).to include(:double, :stringify, :add_one)
        expect(complex_contract_with_requirments.requirements).to be_empty

        res = complex_contract_with_requirments.call(42)
        
        expect(res).to be_success
        expect(res.unwrap).to eq("85")
      end

      it "more complex contract with add_prefix" do
        expect(complex_contract2.requirements).to include(:double, :stringify, :add_one, :add_prefix)

        layer =  Covenant::Container::CommandLayer.new

        layer << add_prefix_contract.of { |input| "Prefix: #{input}" }
        layer << double_contract.of { |input| input * 2 }
        layer << stringify_contract.of { |input| input.to_s }
        layer << add_one_contract.of { |input| input + 1 }

        complex_contract2_with_requirments = layer.provide(complex_contract2)

        result = complex_contract2_with_requirments.call(42)

        expect(result).to be_success
        expect(result.unwrap).to eq("Prefix: 85")
      end
    end

    describe '#handlers_for_requirements' do
      it 'maps requirements to handlers' do
        handlers = runner.handlers_for_requirements(simple_contract)
        expect(handlers).to have_key(:double)
        expect(handlers[:double]).to be_a(Proc)
        expect(handlers[:double].call(5)).to eq(10)
      end
    end
  end
end