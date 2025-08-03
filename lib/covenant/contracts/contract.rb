# frozen_string_literal: true

module Covenant
  module Contracts
    class Contract
      include Monad
      using ColorAliasRefinement

      attr_reader :command, :input, :output

      # def self.run(contract, args)
      #   input_result = contract.input.call(args)
      #   return Result(handler, input_result) if input_result.failure?

      #   result = yield input_result.unwrap
      #   output_result = contract.output.call(result)

      #   Runtime::ExecutionResult.new(contract, contract.command, input_result, output_result)
      # end

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

      def requirements = [@command]

      def call(handler, args)
        input_result = input.call(args)

        return Result(handler, input_result) if input_result.failure?

        result = handler.call(input_result.unwrap)
        output_result = output.call(result)

        Result(handler, input_result, output_result)
      end

      # def call(handler, args) = Contract.run(self, args) { |value| handler.call(value) }

      def can_chain_to?(other_contract) = self.class.can_chain?(self, other_contract)

      def can_chain_from?(other_contract) = self.class.can_chain?(other_contract, self)

      def to_s = self.class.format(input, command, output)

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

      def to_instruction = [:execute, self]
    end
  end
end
