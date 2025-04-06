# frozen_string_literal: true

module Covenant
  class Schemas
    attr_reader :name, :block, :dry_schema

    def initialize(name, &block)
      @name = name
      @dry_schema = Dry::Schema.Params(&block)
    end

    def call(input)
      @dry_schema.call(input)
    end

    def same?(other)
      return false unless other.is_a?(Schemas)

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
      unless dry_schema1.key_map.keys.size == dry_schema2.key_map.keys.size
        return false
      end

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
