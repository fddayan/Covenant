# frozen_string_literal: true

module Covenant
  module Contracts
    class Retry < BaseComposition
      attr_reader :contract, :max_attempts

      delegate :input, :output, to: :contract

      def initialize(contract, max_attempts)
        super()
        @contract = contract
        @max_attempts = max_attempts
      end

      def verify
        true
      end

      def to_s
        "Retry(#{contract} -> #{max_attempts})"
      end
    end
  end
end
