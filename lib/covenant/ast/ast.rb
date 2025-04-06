# frozen_string_literal: true

module Covenant
  module Ast
    class Ast
      def initialize(contract)
        @contract = contract
      end

      def to_ast
        build_ast(@contract)
      end

      private

      def build_ast(contract) # rubocop:disable Metrics/AbcSize,Metrics/MethodLength,Metrics/CyclomaticComplexity
        case contract
        when Contracts::Contract
          {
            type: :contract,
            command: contract.command,
            input: schema_ast(contract.input),
            output: schema_ast(contract.output)
          }
        when Contracts::Map
          {
            type: :map,
            prev_contract: build_ast(contract.prev_contract),
            next_contract: build_ast(contract.next_contract),
            input: schema_ast(contract.input),
            output: schema_ast(contract.output),
            result: schema_comparator_result_ast(contract.verify)
          }
        when SchemaComparatorResult
          {
            type: :schema_comparator_result,
            valid: contract.valid?,
            errors: contract.errors.map(&:to_s)
          }
        when Contracts::Tee
          {
            type: :tee,
            prev_contract: build_ast(contract.prev_contract),
            next_contract: build_ast(contract.next_contract),
            input: schema_ast(contract.input),
            output: schema_ast(contract.output)
          }
        when Contracts::OrElse
          {
            type: :or_else,
            prev_contract: build_ast(contract.prev_contract),
            next_contract: build_ast(contract.next_contract)
          }
        when Contracts::Retry
          {
            type: :retry,
            contract: build_ast(contract.contract)
          }
        when Contracts::Timeout
          {
            type: :timeout,
            contract: build_ast(contract.contract)
          }
        else
          raise "Unknown contract type: #{contract.class}"
        end
      end

      def schema_comparator_result_ast(schema_comparator_result)
        {
          type: :schema_comparator_result,
          valid: schema_comparator_result.valid?,
          errors: schema_comparator_result.errors.map(&:to_s)
        }
      end

      def schema_ast(schema)
        {
          type: :schema,
          name: schema.name,
          properties: schema.keys
        }
      end
    end
  end
end
