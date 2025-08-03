# frozen_string_literal: true

module Covenant
  module Compositions
    class Match < BaseComposition
      attr_reader :prev_contract, :success_contract, :failure_contract

      delegate :input, to: :prev_contract
      delegate :output, to: :success_contract

      def initialize(prev_contract, success_contract, failure_contract)
        super()
        @prev_contract = prev_contract
        @success_contract = success_contract
        @failure_contract = failure_contract
      end

      def command
        "#{@prev_contract.command} -> #{@success_contract.command} || #{@failure_contract.command}"
      end

      def to_instruction
        [:match, prev_contract.to_instruction, success_contract.to_instruction,
         failure_contract.to_instruction]
      end
    end
  end
end
