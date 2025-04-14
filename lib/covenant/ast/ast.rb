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

      def build_ast(contract, opts = {}) # rubocop:disable Metrics/AbcSize,Metrics/MethodLength,Metrics/CyclomaticComplexity
        case contract
        when Contracts::Contract
          {
            type: :contract,
            command: contract.command,
            input: build_ast(contract.input),
            output: build_ast(contract.output),
            opts: opts
          }
        when Contracts::Map
          result = contract.verify
          {
            type: :map,
            prev_contract: build_ast(contract.prev_contract, success: result.success?),
            next_contract: build_ast(contract.next_contract, success: result.success?),
            input: build_ast(contract.input),
            output: build_ast(contract.output),
            result: build_ast(result)
          }
        when Comparable::Result
          {
            type: :struct_compare,
            success: contract.success?,
            errors: contract.unwrap
          }
        when Types::Schema
          {
            type: :struct,
            tag: contract.tag,
            properties: contract.keys
          }
        when Contracts::Tee
          {
            type: :tee,
            prev_contract: build_ast(contract.prev_contract),
            next_contract: build_ast(contract.next_contract),
            input: build_ast(contract.input),
            output: build_ast(contract.output)
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
    end
  end
end
