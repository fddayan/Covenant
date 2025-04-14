# frozen_string_literal: true

module Covenant
  module Types
    class Schema < BaseType
      attr_reader :props

      def initialize(tag, props, parent = nil)
        super(tag, parent, props)
        @props = props.brand_to(self)
        @validator = yield if block_given?
      end

      def brand_to(other_tag)
        Schema.new(@tag, @props, other_tag)
      end

      def call(values)
        return Validator::ValidationResult.success(values) if %i[any void].include?(tag)

        props_validation = @props.validate(values)
        _validate_struct(props_validation)
      end

      def tags
        [@tag, @props.tags]
      end

      def empty?
        @props.empty?
      end

      def [](key)
        @props[key]
      end

      def ==(other)
        compare(other).success?
      end

      def same?(other)
        compare(other)
      end

      def compare(other)
        Comparable.check_struct.call(self, other)
      end

      def -(other)
        case other
        when Scalar, Props
          clone(@props - other)
        when Schema
          @props - other.props
        end
      end

      def +(other)
        case other
        when Scalar, Props
          clone(@props + other)
        when Schema
          new_tag = :"#{@tag}_#{other.tag}"
          Schema.new(new_tag, Props.new([self, other]))
        end
      end

      def clone(props)
        Schema.new(@tag, props, @parent)
      end

      def compositions
        @props.props.each_with_object([]) do |prop, acc|
          next unless prop.is_a?(Schema)

          acc << prop
        end
      end

      def to_a
        @props.to_a
      end

      def prop?(key)
        @props.tag?(key)
      end

      alias tag? prop?

      def keys
        @props.keys
      end

      def pick(*tag)
        Schema.new(@tag, @props.pick(*tag), @parent)
      end

      def omit(*tags)
        Schema.new(@tag, @props.omit(*tags), @parent)
      end

      def size
        @props.size
      end

      def to_s
        "Struct(:#{@tag} => #{@props})"
      end

      def tag_chain
        [props.tag, @tag]
      end

      private

      def _validate_props(values)
        # values.each_with_object({}) do |(key, value), acc|
        #   ap "#{key} => #{value}"
        #   prop = @props[key]
        #   acc[key] = prop.call(value) unless prop.nil?
        # end
        @props.validate(values)
      end

      def _validate_struct(props_validation)
        Covenant::Validator::ValidationResult.new(
          props_validation,
          props_validation
            .values
            .flat_map(&:errors)
            .reject(&:empty?)
        )
      end

      def _validate_all
        @validator.call(self)
      end
    end

    Any = Scalar.new(:any, :any).struct
    Void = Scalar.new(:void, :void).struct
  end
end
