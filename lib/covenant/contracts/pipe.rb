# frozen_string_literal: true

module Covenant
  module Contracts
    class Pipe < BaseComposition
      attr_reader :contracts

      def initialize(contracts)
        super()
        @contracts = contracts
      end

      def build
        @contracts.reduce do |acc, contract|
          acc.and_then(contract)
        end
      end

      def call(input)
        return input if input.is_a?(Runtime::ExecutionResult) && input.failure?

        result = input

        @contracts.each do |contract|
          result = contract.call(result)
          break if result.failure?
        end

        result
      end
    end
  end
end
