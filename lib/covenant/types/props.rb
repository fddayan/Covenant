# frozen_string_literal: true

module Covenant
  module Types
    class Props < BaseType
      include Taggable

      attr_reader :props

      def initialize(props, parent = nil)
        super(props.map(&:tag), parent, props)
        @props = parent ? props.map { |prop| prop.brand_to(parent) } : props
        @props = @props.to_set
      end

      def brand_to(struct)
        Props.new(@props, struct)
      end

      def map(&block)
        @props.map(&block)
      end

      def tags
        @props.map(&:tags)
      end

      def +(other)
        case other
        when Scalar, Schema
          Props.new(props + [other])
        when Props
          Props.new(props + other.props)
        end
      end

      def -(other)
        case other
        when Scalar
          omit other.tag
        when Props
          omit(*other.props.map(&:tag))
        else
          raise ArgumentError, "Expected Prop, Struct or Props got #{other.class}"
        end
      end

      def pick(*tags)
        Props.new(@props.select { |r| tags.include?(r.tag) }, @parent)
      end

      def omit(*tags)
        Props.new(@props.reject { |r| tags.include?(r.tag) }, @parent)
      end

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
        @props.each_with_object({}) do |prop, acc|
          acc[prop.tag] = prop.call(values[prop.tag])
        end
      end

      def include?(tag)
        @props.any? { |r| r.tag == tag }
      end

      def each(&block)
        @props.each(&block)
      end

      def prop?(other_prop)
        other.is_a?(Scalar) && !@props.props.detect { |p| p.tag == other_prop.tag }.nil?
      end

      def [](key)
        props_map[key]
      end

      def tag?(key)
        props_map.key?(key)
      end

      def to_a
        @props
      end

      def keys
        @props.map(&:tag)
      end

      def empty?
        @props.empty?
      end

      def struct_props
        @struct_props ||= @props.select { |prop| prop.is_a?(Schema) }
      end

      def prop_props
        @prop_props ||= @props.select { |prop| prop.is_a?(Scalar) }
      end

      def size
        @props.size
      end

      def to_s
        "Props[#{@props.map(&:to_s).join(', ')}]"
      end

      def props_map
        @props_map ||= @props.to_h { |prop| [prop.tag, prop] }
      end
    end
  end
end
