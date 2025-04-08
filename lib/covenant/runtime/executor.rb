# frozen_string_literal: true

module Covenant
  module Runtime
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
          return ExecutionResult.new(contract, handler, input_result, output_result)
        end

        result = handler.call(input_result.unwrap)
        output_result = contract.output.call(result)

        ExecutionResult.new(contract, handler, input_result, output_result)
      end
    end
  end
end
