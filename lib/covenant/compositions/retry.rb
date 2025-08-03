# frozen_string_literal: true

module Covenant
  module Compositions
    class Retry < BaseComposition
      attr_reader :contract, :max_attempts

      delegate :input, :output, to: :contract

      def initialize(contract, max_attempts)
        super()
        @contract = contract
        @max_attempts = max_attempts
      end

      def verify = true

      def to_s = "Retry(#{contract} -> #{max_attempts})"

      def to_instruction = [:retry, contract.to_instruction, max_attempts]
    end
  end
end
