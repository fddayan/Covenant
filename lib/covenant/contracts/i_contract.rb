# frozen_string_literal: true

module Covenant
  module Contracts
    # Abstract base class for all contracts.
    class IContract
      attr_reader :input, :output

      def initialize(input, output)
        Covenant.assert_any_type_of(input, [Types::Scalar, Types::Props, Types::Schema])
        Covenant.assert_any_type_of(output, [Types::Scalar, Types::Props, Types::Schema])
        @input = input
        @output = output
      end

      def requirements = raise NotImplementedError, "#{self.class} must implement #requirements"

      def self.run(contract, args)
        input_result = contract.input.call(args)
        return Runtime::ExecutionResult.new(contract, input_result) if input_result.failure?

        result = yield input_result.unwrap
        output_result = contract.output.call(result)

        Runtime::ExecutionResult.new(contract, input_result, output_result)
      end
    end

    class SimpleContract < IContract
      def initialize(command, input, output)
        super(input, output)
        Covenant.assert_type(command, Symbol)
        @command = command
      end

      def requirements = [@command]

      def call(handlers, args) = handlers[@command].call(args)
    end

    class ComposableContract < IContract
      def initialize(signatures, contracts, &block)
        super(@signatures.to_a.first, @signatures.to_a.last)
        @signatures = signatures
        @contracts = contracts
        @block = block
      end

      def requirements = @contracts.flat_map(&:requirements).uniq

      def call(handlers, args) = @block.call(handlers, args)
    end

    class FunctorContract < IContract
      def initialize(input, output, &block)
        super(input, output)
        @block = block
      end

      def next_run(runner) = raise NotImplementedError, "#{self.class} must implement #next_run"
    end

    class ContractExec
      def initialize(command_registry, icontract)
        @command_registry = command_registry
        @icontract = icontract
      end

      def handlers_for_requirements
        @icontract.requirements.to_h do |requirement|
          [requirement, @command_registry.handler_for(requirement)]
        end
      end

      def call(args)
        input_result = @icontract.input.call(args)
        return input_result if input_result.failure?

        output_value = @icontract.call(handlers_for_requirements, input_result.unwrap)
        @icontract.output.call(output_value)
      end
    end

    class ContractRunner
      def initialize(command_registry) = @command_registry = command_registry

      def call(icontract, args)
        case icontract
        when SimpleContract, ComposableContract
          ContractExec.new(@command_registry, icontract).call(args)
        when FunctorContract
          icontract.next_run(self, args)
        else
          raise ArgumentError, "Unsupported contract type: #{icontract.class}"
        end
      end
    end
  end
end
