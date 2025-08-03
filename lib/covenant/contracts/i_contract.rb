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

      def to_s = "(#{input} -> #{output})"

      # def self.run(contract, args)
      #   input_result = contract.input.call(args)
      #   return Runtime::ExecutionResult.new(contract, input_result) if input_result.failure?

      #   result = yield input_result.unwrap
      #   output_result = contract.output.call(result)

      #   Runtime::ExecutionResult.new(contract, input_result, output_result)
      # end
    end

    class SimpleContract < IContract
      def initialize(command, input, output)
        super(input, output)
        Covenant.assert_type(command, Symbol)
        @command = command
      end

      def requirements = [@command]

      def call(args, handlers = nil, &)
        return handlers[@command].call(args) if handlers

        return input.call(args) if block_given?

        raise ArgumentError, 'Handlers must be provided if no block is given'
      end
    end

    class ComposableContract < IContract
      def initialize(signatures, contracts, &block)
        super(signatures.first.first, signatures.first.last)
        @signatures = signatures
        @contracts = contracts
        @block = block
      end

      def requirements = @contracts.flat_map(&:requirements).uniq

      def call(handlers, args) = @block.call(handlers, args)

      def to_s = "ComposableContract(#{requirements.map(&:to_s).join(', ')})#{super}"

      # "ComposableContract(#{@signatures.map { |s| s.join(' -> ') }.join(', ')})"
    end

    # class FunctorContract < IContract
    #   def initialize(input, output, &block)
    #     super(input, output)
    #     @block = block
    #   end

    #   def next_run(runner) = raise NotImplementedError, "#{self.class} must implement #next_run"
    # end

    # class ContractExec
    #   def initialize(command_registry, icontract)
    #     @command_registry = command_registry
    #     @icontract = icontract
    #   end

    #   def handlers_for_requirements
    #     @icontract.requirements.to_h do |requirement|
    #       [requirement, @command_registry.handler_for(requirement)]
    #     end
    #   end

    #   def call(args)
    #     input_result = @icontract.input.call(args)
    #     return input_result if input_result.failure?

    #     output_value = @icontract.call(handlers_for_requirements, input_result.unwrap)
    #     @icontract.output.call(output_value)
    #   end
    # end

    class ContractRunner
      def initialize(command_registry) = @command_registry = command_registry

      def call(icontract, args)
        case icontract
        when SimpleContract, ComposableContract
          execute_contract(icontract, args)
        when Compositions::BaseComposition
          execute_functor(icontract, args)
          # icontract.next_run(self, args)
        else
          raise ArgumentError, "Unsupported contract type: #{icontract.class}"
        end
      end

      def execute_contract(icontract, args)
        input_result = icontract.input.call(args)
        return input_result if input_result.failure?

        output_value = icontract.call(handlers_for_requirements(icontract), input_result.unwrap)
        icontract.output.call(output_value)
      end

      def execute_functor(contract, input) # rubocop:disable Metrics/AbcSize,Metrics/CyclomaticComplexity,Metrics/MethodLength
        case contract
        when Compositions::Map
          prev_result = call(contract.prev_contract, input)
          call(contract.next_contract, prev_result)
        when Compositions::Tee
          prev_result = call(contract.prev_contract, input)
          call(contract.next_contract, prev_result)
          prev_result
        when Compositions::OrElse
          prev_result = call(contract.prev_contract, input)
          call(contract.next_contract, input) if prev_result.failure?
        when Compositions::Retry
          call_with_retry(contract, input)
        when Compositions::Match
          prev_result = call(contract.prev_contract, input)
          if prev_result.success?
            call(contract.success_contract, prev_result)
          else
            call(contract.failure_contract, prev_result)
          end
        when Compositions::Timeout
          call_with_timeout(contract, input)
        when Compositions::Transformer
          prev_result = call(contract.prev_contract, input)
          contract.call(prev_result)
        end
      end

      def handlers_for_requirements(icontract)
        icontract.requirements.to_h do |requirement|
          [requirement, @command_registry.handler_for(requirement)]
        end
      end
    end
  end
end
