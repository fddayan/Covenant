# frozen_string_literal: true

module Covenant
  module Contracts
    class Tee < BaseComposition
      attr_reader :prev_contract, :next_contract

      delegate :input, :output, to: :prev_contract

      def initialize(prev_contract, next_contract)
        super()
        @prev_contract = prev_contract
        @next_contract = next_contract
        verify
      end

      def verify
        Contract.can_chain?(@prev_contract, @next_contract)
      end

      def to_s
        "Tee(#{prev_contract} -> #{next_contract})"
      end
    end
  end
end
