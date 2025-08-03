# frozen_string_literal: true

module Covenant
  module Compositions
    class Timeout < BaseComposition
      attr_reader :contract, :seconds

      delegate :input, :output, to: :contract

      def initialize(contract, seconds)
        super()
        @contract = contract
        @seconds = seconds
      end

      def verify = true

      def to_s = "Timeout(#{contract} -> #{seconds})"

      def to_instruction = [:timeout, contract.to_instruction, seconds]
    end
  end
end
