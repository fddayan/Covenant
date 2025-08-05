# frozen_string_literal: true

module Covenant
  module Contracts
    # Abstract base class for all contracts.
    class IContract
      attr_reader :tag, :input, :output, :dependencies
      attr_accessor :layers

      def initialize(tag, input, output, dependencies)
        if self.class == IContract
          raise NotImplementedError, "#{self.class} is abstract; subclass it instead."
        end

        Covenant.assert_any_type_of(input, [Types::Scalar, Types::Props, Types::Schema])
        Covenant.assert_any_type_of(output, [Types::Scalar, Types::Props, Types::Schema])
        @tag = tag
        @input = input
        @output = output
        @dependencies = dependencies
        @layers = nil
      end

      def of(&) = Handlers::ContractHandler.new(self, &)

      def provide(command_layer)
        @layers = command_layer
        self
      end

      def requirements_provided = @layers&.handler_names || []

      def handler_for(command) = @layers.handler_for(command)

      def requirements = raise NotImplementedError, "#{self.class} must implement #requirements"

      def to_s = "(#{input} -> #{output})"
    end

    class SimpleContract < IContract
      attr_reader :command

      def initialize(command, input, output)
        Covenant.assert_type(command, Symbol)
        super(command, input, output, [command])
        @command = command
      end

      def requirements = [@command]

      def handler = @handler ||= handler_for(@command)

      def call(args)
        raise ArgumentError, "Handler for :#{@command} not found" unless handler

        pipe(
          Validator::ValidationResult.success(args),
          @input,
          handler,
          @output
        )
      end

      def pipe(*args)
        initial = args.shift
        args.reduce(initial) do |acc, step|
          case acc
          when Validator::ValidationResult
            break acc if acc.failure?

            step.call(acc.unwrap) if step.respond_to?(:call)
          else
            step.call(acc) if step.respond_to?(:call)
          end
        end
      end
    end

    class ComposableContract < IContract
      attr_reader :signatures, :contracts, :block, :command

      def initialize(command, signatures, contracts, &block)
        super(command, signatures.first.first, signatures.first.last, contracts)
        @command = command
        @signatures = signatures
        @contracts = contracts
        @block = block
      end

      def _requirements = @contracts.flat_map(&:requirements).uniq

      def requirements = _requirements - requirements_provided

      def contracts_with_layer = @contracts.map { |contract| contract.provide(layers) }

      def handlers_for_contracts
        contracts_with_layer.to_h do |contract|
          [contract.command, contract]
        end
      end

      def call(args) = @block.call(handlers_for_contracts, args)

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

        # handlers_for_requirements(icontract),
        output_value = icontract.call(input_result.unwrap)
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
