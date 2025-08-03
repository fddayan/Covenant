# frozen_string_literal: true

module Covenant
  module Handlers
    class PipeHandler
      def initialize(*handlers) = @handlers = handlers

      def call(input)
        @handlers.reduce(input) do |current_input, handler|
          handler.call(current_input)
        end
      end
    end

    def self.pipe(*handlers)
      PipeHandler.new(*handlers)
    end
  end
end
