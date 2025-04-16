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

      def call(input)
        return input if input.is_a?(ExecutionResult) && input.failure?

        contract.call(fetch_handler, ExecutionResult.unwrap(input))
      end
    end
  end
end
