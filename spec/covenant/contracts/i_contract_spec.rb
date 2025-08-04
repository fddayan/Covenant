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
      # ap create_post_payload.tag
      # ap create_post_contract.input.tag
      # ap create_post_payload == create_post_contract.input

      expect(create_post_contract.input.tag).to eq(create_post_payload.tag)
      expect(create_post_contract.output.tag).to eq(post_schema.tag)
    end

    it "runs successfully with valid input" do
      input = { user: { id: 1, name: 'Fede', email: 'fede@example.com' }, post: { title: 'Hello World', body: 'This is a test post.' } }
      
      layer = Covenant::Container::CommandLayer.new
      layer.register(
        :create_post_contract, ->(input) { { title: input[:post][:title], body: input[:post][:body] } }
      )
      create_post_contract.provide(layer)

      # result = create_post_contract.call(input) do
      #   { title: input[:post][:title], body: input[:post][:body] }
      # end

      result = create_post_contract.call(input) 
      # expect(result).to be_a(Covenant::Runtime::ExecutionResult)
      expect(result).to be_a(Covenant::Validator::ValidationResult)
    end

  end

  # describe 'IContract' do
  #   it 'initializes with valid input and output types' do
  #     contract = Covenant::Contracts::IContract.new(int_type, string_type)
  #     expect(contract.input).to eq(int_type)
  #     expect(contract.output).to eq(string_type)
  #   end

  #   it 'raises error for invalid input type' do
  #     expect do
  #       Covenant::Contracts::IContract.new('invalid', string_type)
  #     end.to raise_error(ArgumentError, /Expected one of types/)
  #   end

  #   it 'raises error for invalid output type' do
  #     expect do
  #       Covenant::Contracts::IContract.new(int_type, 'invalid')
  #     end.to raise_error(ArgumentError, /Expected one of types/)
  #   end

  #   it 'raises NotImplementedError for requirements method' do
  #     contract = Covenant::Contracts::IContract.new(int_type, string_type)
  #     expect do
  #       contract.requirements
  #     end.to raise_error(NotImplementedError, /must implement #requirements/)
  #   end
  # end

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
      layer.register(:double, handlers)
      result = simple_contract.provide(layer).call(5)
      expect(result.unwrap).to eq(10)
    end
  end

  describe 'ComposableContract' do
    # it 'raises error during initialization due to implementation issue' do
    #   # ComposableContract has a bug - it expects signatures to be a hash or different structure
    #   expect do
    #     Covenant::Contracts::ComposableContract.new(
    #       [int_type, int_type],
    #       []
    #     ) { |_, _| }
    #   end.to raise_error(NoMethodError, /undefined method `first'/)
    # end
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

        layer.register(:double, ->(input) { input * 2 })
        layer.register(:stringify, ->(input) { input.to_s })
        layer.register(:add_one, ->(input) { input + 1 })
        layer.register(:add_prefix, ->(input) { "Prefix: #{input}" })

        complex_contract_with_requirments = complex_contract.provide(layer)

        expect(complex_contract_with_requirments.requirements_provided).to include(:double, :stringify, :add_one)
        expect(complex_contract_with_requirments.requirements).to be_empty
        res = complex_contract_with_requirments.call(42)
        expect(res).to be_success
        expect(res.unwrap).to eq("85")
      end

      it "more complex contract with add_prefix" do
        expect(complex_contract2.requirements).to include(:double, :stringify, :add_one, :add_prefix)

        layer =  Covenant::Container::CommandLayer.new

        layer.register(:double, ->(input) { input * 2 })
        layer.register(:stringify, ->(input) { input.to_s })
        layer.register(:add_one, ->(input) { input + 1 })
        layer.register(:add_prefix, ->(input) { "Prefix: #{input}" })

        complex_contract2_with_requirments = complex_contract2.provide(layer)

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