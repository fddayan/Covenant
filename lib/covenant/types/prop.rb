# frozen_string_literal: true

module Covenant
  module Types
    # Prop is a blueprint for a property
    class Prop
      include Taggable

      def initialize(tag, validator)
        @tag = tag
        @validator = validator
        @name = tag
        tag! tag
      end

      # def name
      #   first.first
      # end

      # def type
      #   first.second
      # end

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

      # def inspect
      #   to_s
      # end

      # def same?(other)
      #   TypeCompare.same?(self, other)
      # end

      def ==(other)
        # return true if equal?(other)
        # return false unless other.is_a?(self.class)
        # && @validator == other.validator

        @tag == other.tag
      end

      def call(value)
        raise ArgumentError, 'Expected NOT a hash' if value.is_a?(Hash)
        raise ArgumentError, 'Expected NOT an array' if value.is_a?(Array)

        @validator.call(value)
      end
    end
  end
end
