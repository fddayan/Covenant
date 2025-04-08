# frozen_string_literal: true

module Covenant
  module Types
    class Struct
      include Taggable

      attr_reader :props

      alias name tag

      def initialize(tag, props, parent = nil)
        tag! tag
        parent! parent if parent
        @props = props.brand_to(self)
      end

      def brand_to(struct)
        Struct.new(@tag, @props, struct)
      end

      def call(values)
        return Validator::ValidationResult.success(values) if %i[any void].include?(tag)

        props_validation = _validate_props(values)
        _validate_struct(props_validation)
      end

      def -(other)
        case other
        when Prop
          @props - Props.new(other)
        when Struct
          @props - other.props
        when Props
          @props - other
        end
      end

      def empty?
        @props.empty?
      end

      def ==(other)
        StructCompare.new(self, other).success?
      end

      def same?(other)
        StructCompare.new(self, other)
      end

      def compare(other)
        StructCompare.new(self, other)
      end

      def +(other)
        case other
        when Prop, Struct
          Props.new([self, other])
        when Props
          Props.new([self] + other.props)
        end
      end

      def compositions
        @props.props.each_with_object([]) do |prop, acc|
          next unless prop.is_a?(Struct)

          acc << prop
        end
      end

      def to_a
        @props.to_a
      end

      def prop?(key)
        @props.key?(key)
      end

      def keys
        @props.keys
      end

      def pick(tag)
        @props[tag]
      end

      def size
        @props.size
      end

      def to_s
        "Struct(:#{@tag} => #{@props})"
      end

      private

      def _validate_props(values)
        values.each_with_object({}) do |(key, value), acc|
          prop = @props[key]
          acc[key] = prop.call(value) unless prop.nil?
        end
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
    end

    Any = Prop.new(:any, :any).struct
    Void = Prop.new(:void, :void).struct
  end
end
