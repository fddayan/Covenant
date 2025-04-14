# frozen_string_literal: true

module Covenant
  module Contracts
    class Contract
      include Monad
      using ColorAliasRefinement

      attr_reader :command, :input, :output

      def Result(handler, input_result, output_result = nil) # rubocop:disable Naming/MethodName
        Runtime::ExecutionResult.new(self, handler, input_result, output_result)
      end

      def initialize(command, input, output)
        Covenant.assert_type(command, Symbol)
        Covenant.assert_any_type_of(input, [Types::Scalar, Types::Props, Types::Schema])
        Covenant.assert_any_type_of(output, [Types::Scalar, Types::Props, Types::Schema])

        @command = command
        @input = input
        @output = output
      end

      def call(handler, args)
        input_result = input.call(args)

        return Result(handler, input_result) if input_result.failure?

        result = handler.call(input_result.unwrap)
        output_result = output.call(result)

        Result(handler, input_result, output_result)
      end

      def can_chain_to?(other_contract)
        self.class.can_chain?(self, other_contract)
      end

      def can_chain_from?(other_contract)
        self.class.can_chain?(other_contract, self)
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
