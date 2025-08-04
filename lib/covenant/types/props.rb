# frozen_string_literal: true

module Covenant
  module Types
    class Props < BaseType
      include Taggable

      attr_reader :_props

      def self.smart_new(props, parent = nil)
        case props
        when Hash
          Props.from_hash(props, parent)
        when Props
          props
        else
          raise ArgumentError, "Expected a Hash or Props got #{props.class}"
        end
      end

      def self.from_hash(hash, parent = nil)
        raise ArgumentError, "Expected a hash got #{hash.class}" unless hash.is_a?(Hash)

        new(hash, parent)
      end

      def merge_props_with_scalar(scalar) = @_props.merge(scalar.tag => scalar)

      def merge_props_with_schema(schema) = @_props.merge(schema.tag => schema)

      def merge_props_with_props(other_props) = @_props.merge(other_props._props)

      def merge(other)
        case other
        when Scalar
          merge_props_with_scalar(other)
        when Schema
          merge_props_with_schema(other)
        when Props
          merge_props_with_props(other)
        else
          raise ArgumentError, "Expected Scalar, Schema or Props got #{other.class}"
        end
      end

      def initialize(props, parent = nil)
        super(props.values.map(&:tag), parent, props)

        raise 'props must be a hash' unless props.is_a?(Hash)

        @_props = props
        # @props = parent ? props.map { |prop| prop.brand_to(parent) } : props
        # @props = @props.to_set
      end

      def values = @_props.values
      alias props values

      def brand_to(struct) = Props.new(@_props, struct)

      def map(&) = @_props.values.map(&)

      def tags
        if @parent
          @_props.values.map do |prop|
            if prop.is_a?(Schema)
              # For nested Schemas, include their internal tag structure
              [prop.tag, prop.props.tags]
            else
              [@parent, prop.tag]
            end
          end
        else
          @_props.values.map(&:tags)
        end
      end

      def +(other) = Props.new(merge(other), @parent)

      def -(other)
        case other
        when Scalar
          omit other.tag
        when Props
          omit(*other.props.values.map(&:tag))
        else
          raise ArgumentError, "Expected Prop, Struct or Props got #{other.class}"
        end
      end

      def pick(*tags) = Props.new(@_props.select { |_name, v| tags.include?(v.tag) }, @parent)

      def omit(*tags) = Props.new(@_props.reject { |_name, v| tags.include?(v.tag) }, @parent)

      alias except omit
      alias select pick
      alias filter pick
      alias reject omit

      def validate(values)
        return Validator::ValidationResult.success(values) if %i[any void].include?(tag)

        validate_all(values).reject do |key, result|
          !values.key?(key) && result.success?
        end
      end

      def validate_all(values)
        return {} unless values

        # @_props.each_with_object({}) do |prop, acc|
        #   acc[prop.tag] = prop.call(values[prop.tag])
        # end

        @_props.each_with_object({}) do |(key, prop), acc|
          acc[key] = prop.call(values[key])
        end

        # @_props.transform_values do |key, prop|
        #   prop.call(values[key])
        # end
      end

      def zip(other_props)
        @_props.values.map do |prop|
          [prop, other_props[prop.tag]]
        end
      end

      def include?(tag) = @_props.any? { |r| r.tag == tag }

      def each(&) = @_props.each(&)

      def prop?(other_prop) = other.is_a?(Scalar) && !detect { |p| p.tag == other_prop.tag }.nil?

      def detect(&) = @_props.detect(&)

      def [](key) = props_map[key]

      def tag?(key) = props_map.key?(key)

      def to_a = @_props.to_a

      def keys = @_props.values.map(&:tag)

      def empty? = @_props.empty?

      def struct_props = @struct_props ||= @_props.values.select { |prop| prop.is_a?(Schema) }

      def prop_props = @prop_props ||= @_props.values.select { |prop| prop.is_a?(Scalar) }

      def size = @_props.size

      def to_s = "Props[#{@_props.map(&:to_s).join(', ')}]"

      # def props_map = @props_map ||= @_props.to_h { |prop| [prop.tag, prop] }
      def props_map = @_props
    end
  end
end
