# frozen_string_literal: true

module Covenant
  module Container
    class CommandRegistry
      def initialize = @layers = []

      def register_layer(layer) = @layers << layer

      def assert_handlers(requirements)
        requirements.reject do |req|
          @layers.any? { |layer| layer.handler?(req) }
        end

        # if missing.any?
        #   raise Covenant::Runtime::ExecutionError,
        #         "Missing handlers: #{missing.join(', ')}"
        # end
      end

      # def command?(command) = @layers.any? { |layer| layer.has_command?(command) }

      # def commands = @layers.flat_map(&:commands).uniq

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
