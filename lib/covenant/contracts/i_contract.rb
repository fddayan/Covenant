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
      attr_reader :command

      def initialize(command, input, output)
        super(input, output)
        Covenant.assert_type(command, Symbol)
        @command = command
      end

      def requirements = [@command]

      def call(args, handler = nil, &)
        # return handlers[@command].call(args) if handlers
        return handler.call(args) if handler

        return input.call(args) if block_given?

        raise ArgumentError, 'Handlers must be provided if no block is given'
      end
    end

    class ComposableContract < IContract
      attr_reader :signatures, :contracts, :block, :command

      def initialize(command, signatures, contracts, &block)
        super(signatures.first.first, signatures.first.last)
        @command = command
        @signatures = signatures
        @contracts = contracts
        @block = block
      end

      def requirements = @contracts.flat_map(&:requirements).uniq

      def call(handlers, args) = @block.call(handlers, args)

      def to_s = "ComposableContract(#{requirements.map(&:to_s).join(', ')})#{super}"
    end

    class ContractRunner
      def initialize(command_registry) = @command_registry = command_registry

      def call(icontract, args)
        case icontract
        when SimpleContract, ComposableContract
          execute_contract(icontract, args)
        when Compositions::BaseComposition
          execute_functor(icontract, args)
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
        case icontract
        when SimpleContract
          { icontract.command => @command_registry.handler_for(icontract.command) }
        when ComposableContract
          handlers = icontract.contracts.map do |contract|
            handlers_for_requirements(contract)
          end.reduce({}, &:merge)

          handlers.merge({ icontract.command => ->(args) { icontract.call(handlers, args) } })
        else
          raise ArgumentError, "Unsupported contract type: #{icontract.class}"
        end
      end

      def build_composable_contract_handler(contract)
        handlers = handlers_for_requirements(contract)
        ->(args) { contract.call(handlers, args) }
      end
    end
  end
end
