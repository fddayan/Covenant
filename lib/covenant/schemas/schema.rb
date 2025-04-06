# frozen_string_literal: true

module Covenant
  module Schemas
    class Schema
      attr_reader :name, :block, :dry_schema

      def initialize(name, &block)
        @name = name
        @dry_schema = Dry::Schema.Params(&block)
      end

      def call(input)
        @dry_schema.call(input)
      end

      def same?(other)
        return false unless other.is_a?(Schema)

        SchemaComparator.new(self, other).same?
      end

      def to_ast
        @dry_schema.to_ast
      end

      def keys
        @dry_schema.key_map.keys.map { |t| t.name.to_sym }
      end

      def to_s
        @dry_schema.key_map.keys.map(&:name).join(', ')
      end
    end
  end
end
