# frozen_string_literal: true

module Covenant
  module Container
    class CommandRegistry
      def initialize
        @layers = []
      end

      def register_layer(layer)
        @layers << layer
      end

      def handler_for(schema)
        @layers.each do |layer|
          handler = layer.handler_for(schema)
          return handler if handler
        end

        raise HandlerNotFoundError,
              "No handler found for schema: #{schema.name}"
      end
    end
  end
end
