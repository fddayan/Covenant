# frozen_string_literal: true

module Covenant
  module Contracts
    class Contract
      include Monad
      using ColorAliasRefinement

      attr_reader :command, :input, :output

      def initialize(command, input, output)
        Covenant.assert_type(command, Symbol)
        Covenant.assert_type(input, Schemas::Schema)
        Covenant.assert_type(output, Schemas::Schema)

        @command = command
        @input = input
        @output = output
      end

      def can_chain_to?(other_contract)
        other_contract.output.same?(input)
      end

      def can_chain_from?(other_contract)
        output.same?(other_contract.input)
      end

      def to_s
        self.class.format(input, command, output)
      end

      def self.format(input, command, output)
        [
          'Contract'.contract_text,
          '('.symbols_text,
          input.to_s.input_text,
          ' -> '.symbols_text,
          command.to_s.command_text,
          ' -> '.symbols_text,
          output.to_s.output_text,
          ')'.symbols_text
        ].join
      end

      def self.can_chain?(contract_a, contract_b)
        contract_a.output.same?(contract_b.input)
      end
    end
  end
end
