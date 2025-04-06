# frozen_string_literal: true

module Covenant
  module Contracts
    class Map < BaseComposition
      using ColorAliasRefinement
      attr_reader :prev_contract, :next_contract

      delegate :input, to: :prev_contract
      delegate :output, to: :next_contract

      def initialize(prev_contract, next_contract)
        super()
        @prev_contract = prev_contract
        @next_contract = next_contract
      end

      def verify
        Contract.can_chain?(@prev_contract, @next_contract)
      end

      def valid?
        verify.valid?
      end

      def self.format(input, output)
        [
          'Map'.compositon_text,
          '('.symbols_text,
          input.to_s.input_text,
          ' -> '.symbols_text,
          output.to_s.output_text,
          ')'.symbols_text
        ].join
      end

      def to_s
        [
          'Map'.compositon_text,
          '('.symbols_text,
          input.name.to_s.input_text,
          ' -> '.symbols_text,
          output.name.to_s.output_text,
          ', '.symbols_text,
          prev_contract,
          ' => '.compositon_text,
          next_contract,
          ')'.symbols_text
        ].join
      end
    end
  end
end
