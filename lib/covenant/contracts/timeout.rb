# frozen_string_literal: true

module Covenant
  module Contracts
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
    end
  end
end
