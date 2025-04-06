# frozen_string_literal: true

module Covenant
  module Contracts
    class OrElse < BaseComposition
      attr_reader :prev_contract, :next_contract

      def initialize(prev_contract, next_contract)
        super()
        @prev_contract = prev_contract
        @next_contract = next_contract
      end

      def verify
        @prev_contract.output.call(@next_contract.input)
      end

      def to_s
        "OrElse(#{prev_contract} -> #{next_contract})"
      end
    end
  end
end
