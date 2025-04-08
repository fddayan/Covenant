# frozen_string_literal: true

module Covenant
  module Runtime
    class ExecutionResult
      attr_reader :contract, :handler, :input_validation_result, :output_validation_result

      def initialize(contract, handler, input_validation_result, output_validation_result)
        @contract = contract
        @handler = handler
        @input_validation_result = input_validation_result
        @output_validation_result = output_validation_result
      end

      def value
        @output_validation_result.value
      end

      def success?
        @output_validation_result.success? && @input_validation_result.success?
      end

      def failure?
        !success?
      end

      def blame
        return if success?

        from = @input_validation_result.failure? ? 'input' : 'output'

        [
          @handler.to_s.red,
          'failed to validate'.magenta,
          from.red,
          'for'.magenta,
          @contract.command.to_s.red,
          'with'.magenta,
          errors.join(', ').red
        ].join(' ')
        # "#{@handler} did not follow #{from} contract #{@contract.command}"
      end

      def unwrap
        return @output_validation_result.unwrap if success?

        raise 'Cannot unwrap a failed result'
      end

      def errors
        @output_validation_result.errors + @input_validation_result.errors
      end
    end

    class Executor
      attr_reader :contract

      def initialize(command_registry, contract)
        @command_registry = command_registry
        @contract = contract
      end

      def fetch_handler
        @command_registry.handler_for(@contract.command)
      end

      def call(input) # rubocop:disable Metrics/AbcSize
        return input if input.is_a?(ExecutionResult) && input.failure?

        input = input.value if input.is_a?(ExecutionResult)

        handler = fetch_handler
        input_result = contract.input.call(input)

        if input_result.failure?
          return ExecutionResult.new(
            contract,
            handler,
            input_result,
            output_result
          )
        end

        result = handler.call(input_result.unwrap)
        output_result = contract.output.call(result)

        ExecutionResult.new(contract, handler, input_result, output_result)
      end
    end

    class Runner
      def initialize(command_registry)
        @command_registry = command_registry
      end

      def call(contract, input) # rubocop:disable Metrics/MethodLength,Metrics/AbcSize
        case contract
        when Contracts::Contract
          Executor.new(@command_registry, contract).call(input)
        when Contracts::Map
          prev_result = call(contract.prev_contract, input)
          call(contract.next_contract, prev_result)
        when Contracts::Tee
          prev_result = call(contract.prev_contract, input)
          call(contract.next_contract, prev_result)
          prev_result
        when Contracts::OrElse
          prev_result = call(contract.prev_contract, input)
          call(contract.next_contract, input) if prev_result.error?
        when Contracts::Retry
          call_with_retry(contract, input)
        else
          raise "Unknown effect type: #{contract.class}"
        end
      end

      def call_with_retry(contract, input)
        attempts = 0
        begin
          call(contract.contract, input)
        rescue StandardError => e
          attempts += 1
          retry if attempts < contract.max_attempts
          raise e
        end
      end

      def call_with_timeout(contract, input)
        result = nil
        Timeout.timeout(contract.seconds) do
          result = call(contract.contract, input)
        end
        result
      end
    end
  end
end
