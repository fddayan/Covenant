# frozen_string_literal: true

module Covenant
  module Schemas
    class SchemaComparator
      attr_reader :schema1, :schema2

      def initialize(schema1, schema2)
        @schema1 = schema1
        @schema2 = schema2
      end

      def name1
        schema1.name
      end

      def name2
        schema2.name
      end

      def dry_schema1
        schema1.dry_schema
      end

      def dry_schema2
        schema2.dry_schema
      end

      def same?
        SchemaComparatorResult.new(schema1, schema2).tap do |r|
          missing_keys(r)
          # r.add 'Key size mismatch' unless key_size?
          # r.add 'AST mismatch' unless schema1.to_ast == schema2.to_ast
        end
        # && key_names?
        # &&
        # key_types? &&
        # key_optionals?
      end

      def missing_keys(result)
        missing = dry_schema2.key_map.keys - dry_schema1.key_map.keys

        return unless missing.any?

        result.add(
          "Missing keys '#{missing.map(&:name).join(', ')}' " \
          "in schema '#{name1}' from schena '#{name2}'"
        )
      end

      def key_size?
        return false unless dry_schema1.key_map.keys.size == dry_schema2.key_map.keys.size

        true
      end

      def key_names?
        return false unless dry_schema1.key_map.keys.all? do |key|
          dry_schema2.key_map.keys.include?(key) # rubocop:disable Performance/InefficientHashSearch
        end

        true
      end

      def key_types?
        return false unless dry_schema1.key_map.keys.all? do |key|
          dry_schema1[key].type == dry_schema2[key].type
        end

        true
      end

      def key_optionals?
        return false unless dry_schema1.key_map.keys.all? do |key|
          dry_schema1[key].optional? == dry_schema2[key].optional?
        end

        true
      end
    end
  end
end
