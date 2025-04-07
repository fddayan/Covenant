# frozen_string_literal: true

module Covenant
  module Runtime
    class Executor
      attr_reader :contract

      def initialize(command_registry, contract)
        @command_registry = command_registry
        @contract = contract
      end

      def handler
        @command_registry.handler_for(@contract.command)
      end

      def call(input)
        if input.is_a?(Covenant::Validator::ValidationResult)
          return input if input.failure?

          input = input.value
        end

        input_result = contract.input.call(input)
        result = handler.call(input_result.unwrap)
        contract.output.call(result)
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
