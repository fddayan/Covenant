# frozen_string_literal: true

module Covenant
  module Ast
    class AstCheckResult
      attr_reader :success, :errors

      def self.success(node) = new node: node, errors: []

      def self.failure(node, errors) = new(node:, errors: errors)

      def initialize(node:, errors:)
        @node = node
        @errors = AstCheckError.new(errors)
      end

      def success? = @errors.nil? || @errors.empty?

      def failure? = !success?

      def unwrap = @errors

      def to_s
        if success?
          "#{self.class}(Success)"
        else
          format_error
        end
      end

      private

      def format_contract(contract)
        format(
          '(:%<input>s -> %<command>s -> :%<output>s)',
          input: contract.dig(:input, :tag).to_s.colorize(:blue),
          command: contract[:command].to_s.colorize(:cyan),
          output: contract.dig(:output, :tag).to_s.colorize(:blue)
        )
      end

      def format_error
        format(
          '%<type>s[%<prev_contract>s -> %<next_contract>s] ! %<errors>s',
          type: @node[:type].to_s.colorize(:yellow),
          prev_contract: format_contract(@node[:prev_contract]),
          next_contract: format_contract(@node[:next_contract]),
          errors: @errors.to_s.colorize(:red)
        )
      end
    end
  end
end
