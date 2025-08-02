# frozen_string_literal: true

module Covenant
  module Compositions
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

      module ClassMethods
        def pipe(*contracts) = Pipe.new(contracts).build

        def match(success:, failure:) = ->(prev) { Match.new(prev, success, failure) }

        def tee(contract) = ->(prev) { Tee.new(prev, contract) }

        def map(contract) = ->(prev) { Map.new(prev, contract) }

        def and_then(contract) = ->(prev) { Map.new(prev, contract) }

        def if_then(condition, contract) = ->(prev) { IfThen.new(prev, condition, contract) }

        def unless_then(condition, contract)
          lambda { |prev|
            UnlessThen.new(prev, condition, contract)
          }
        end

        # def proc_or_class(contract) = contract.is_a?(Proc) ? contract.call(self) : contract
      end

      extend ClassMethods
    end
  end
end
