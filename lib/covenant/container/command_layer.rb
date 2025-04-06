# frozen_string_literal: true

module Covenant
  module Container
    class CommandLayer
      def initialize
        @handlers = {}
      end

      def register(schema, handler)
        @handlers[schema] = handler
        self
      end

      def handler_for(schema)
        @handlers[schema]
      end
    end
  end
end
