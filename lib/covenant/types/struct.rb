# frozen_string_literal: true

module Covenant
  module Types
    class Struct
      include Taggable

      attr_reader :props

      def initialize(tag, props)
        @props = props
        tag! tag
      end

      def call(values)
        props_validation = _validate_props(values)

        _validate_struct(props_validation)
      end

      def +(other)
        case other
        when Prop, Struct
          Props.new([self, other])
        when Props
          Props.new([self] + other.props)
        end
      end

      def prop?(key)
        @props.key?(key)
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
