# frozen_string_literal: true

module Covenant
  module Types
    class StructCompare
      attr_reader :errors

      def initialize(struct_a, struct_b)
        unless struct_a.is_a?(Struct) && struct_b.is_a?(Struct)
          raise ArgumentError,
                'Expected Struct'
        end

        @struct_a = struct_a
        @struct_b = struct_b
        @errors = []
        validate
      end

      def success?
        @errors.empty?
      end

      def failure?
        !success?
      end

      private

      def validate # rubocop:disable Metrics/AbcSize
        add_error('Struct tags are not the same') do
          @struct_a.tag != @struct_b.tag
        end
        add_error('Struct props size is not the same') do
          @struct_a.size != @struct_b.size
        end

        (@struct_a.to_a + @struct_b.to_a).group_by(&:tag).each_value do |pairs|
          next unless pairs.first.is_a?(Struct)

          comparer = StructCompare.new(pairs.first, pairs.last)
          comparer.validate
          @errors += comparer.errors
        end
      end

      def add_error(error)
        @errors << error if yield
      end
    end

    class Struct
      include Taggable

      attr_reader :props

      alias name tag

      def initialize(tag, props)
        @props = props
        tag! tag
      end

      def call(values)
        props_validation = _validate_props(values)

        _validate_struct(props_validation)
      end

      def ==(other)
        StructCompare.new(self, other).success?
      end

      def same?(other)
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

      def to_a
        @props.to_a
      end

      def prop?(key)
        @props.key?(key)
      end

      def keys
        @props.keys
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
          props_validation.values
            .flat_map(&:errors)
            .reject(&:empty?)
        )
      end
    end
  end
end
