# frozen_string_literal: true

module Covenant
  module Handlers
    class ContractHandler
      def initialize(contract) = @contract = contract

      def tag = @contract.command

      def call(args) = @contract.call(args)
    end

    class PipeHandler
      def initialize(*handlers) = @handlers = handlers

      def call(input)
        @handlers.reduce(input) do |current_input, handler|
          case current_input
          when Covenant::Validator::ValidationResult
            handler.call(current_input.unwrap)
          else
            handler.call(current_input)
          end
          # handler.call(current_input)
        end
      end
    end

    def self.pipe(*handlers)
      PipeHandler.new(*handlers)
    end
  end
end
