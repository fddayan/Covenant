# frozen_string_literal: true

module Covenant
  module Runtime
    class Runner
      def initialize(command_registry)
        @command_registry = command_registry
      end

      def call(contract, input) # rubocop:disable Metrics/MethodLength,Metrics/AbcSize,Metrics/CyclomaticComplexity
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
          call(contract.next_contract, input) if prev_result.failure?
        when Contracts::Retry
          call_with_retry(contract, input)
        when Contracts::Match
          prev_result = call(contract.prev_contract, input)
          if prev_result.success?
            call(contract.success_contract, prev_result)
          else
            call(contract.failure_contract, prev_result)
          end
        when Contracts::Timeout
          call_with_timeout(contract, input)
        when Covenant::Contracts::Transformer
          prev_result = call(contract.prev_contract, input)
          contract.call(prev_result)
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
