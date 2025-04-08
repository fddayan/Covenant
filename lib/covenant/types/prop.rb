# frozen_string_literal: true

module Covenant
  module Types
    # Prop is a blueprint for a property
    class Prop
      include Taggable

      def initialize(tag, validator, parent = nil)
        @tag = tag
        @validator = validator
        @name = tag
        tag! tag
        parent! parent if parent
      end

      def brand_to(struct)
        Prop.new(@tag, @validator, struct)
      end

      def struct
        Types::Struct.new(tag, to_props)
      end

      def to_props
        Types::Props.new([self])
      end

      def name
        tag
      end

      def to_s
        "Prop(:#{@tag})"
      end

      def +(other)
        case other
        when Prop, Struct
          Props.new([self, other])
        when Props
          Props.new([self] + other.props)
        end
      end

      def ==(other)
        tag_chain == other.tag_chain
      end

      def call(value)
        raise ArgumentError, 'Expected NOT a hash' if value.is_a?(Hash)
        raise ArgumentError, 'Expected NOT an array' if value.is_a?(Array)

        @validator.call(value)
      end
    end
  end
end
