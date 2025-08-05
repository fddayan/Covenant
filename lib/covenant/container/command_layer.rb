# frozen_string_literal: true

module Covenant
  module Container
    class CommandLayer
      def self.merge(*args)
        args.each_with_object(new) do |arg, layer|
          layer.merge!(arg)
        end
      end

      attr_reader :handlers

      def initialize = @handlers = {}

      def register(schema, handler)
        @handlers[schema] = handler
        self
      end

      def handler_names = @handlers.keys

      def handler?(schema) = @handlers.key?(schema)

      def handler_for(schema) = @handlers[schema]

      def merge!(other_layer)
        @handlers.merge!(other_layer.handlers)
        self
      end

      def <<(handler)
        @handlers[handler.tag] = handler
        self
      end
    end
  end
end
