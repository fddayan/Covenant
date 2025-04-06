# frozen_string_literal: true

module Covenant
  module Schemas
    class SchemaComparatorResult
      attr_reader :schema1, :schema2, :errors

      def initialize(schema1, schema2)
        @schema1 = schema1
        @schema2 = schema2
        @errors = []
      end

      def valid?
        @errors.empty?
      end

      def invalid?
        !valid?
      end

      def add(error)
        @errors << error
      end

      def to_s
        [
          'Compare'.colorize(:yellow),
          '('.colorize(:red),
          schema1.name.to_s.colorize(:green),
          ' -> '.colorize(:red),
          schema2.name.to_s.colorize(:green),
          ', '.colorize(:red),
          "\"#{messages.to_s.colorize(:silver)}\"",
          ')'.colorize(:red)
        ].join
      end
    end
  end
end
