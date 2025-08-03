# frozen_string_literal: true

module Covenant
  module Compositions
    class Tee < BaseComposition
      attr_reader :prev_contract, :next_contract

      delegate :input, :output, to: :prev_contract

      def initialize(prev_contract, next_contract)
        super()
        @prev_contract = prev_contract
        @next_contract = next_contract
        verify
      end

      def requirements = [@prev_contract, @next_contract].map(&:requirements).flatten

      def verify = Covenant::Contract.can_chain?(@prev_contract, @next_contract)

      def to_s = "Tee(#{prev_contract} -> #{next_contract})"

      def to_instruction = [:tee, prev_contract.to_instruction, next_contract.to_instruction]
    end
  end
end
