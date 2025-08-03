# frozen_string_literal: true

module Covenant
  module Types
    # Prop is a blueprint for a property
    class Scalar < BaseProp
      include Taggable

      def initialize(tag, validator, parent = nil)
        super(tag, parent)
        @validator = validator
      end

      def brand_to(struct) = Scalar.new(@tag, @validator, struct)

      def array = PropArray.new(self)

      def optional
        wrapped = Validator::Validation.optional(@validator)
        Scalar.new(@tag, wrapped, @parent)
      end

      def to_s = "Prop(:#{@tag})"

      def inspect = "Prop(#{@tag})"

      def merge_scalar_with_scalar(other) = { @tag => self }.merge(other.tag => other)

      def merge_scalar_with_schema(other) = { @tag => self }.merge(other.props.props)

      def merge_scalar_with_props(other) = { @tag => self }.merge(other.props)

      def merge(other)
        case other
        when Scalar
          merge_scalar_with_scalar(other)
        when Schema
          merge_scalar_with_schema(other)
        when Props
          merge_scalar_with_props(other)
        else
          raise ArgumentError,
                "Expected Scalar, Schema or Props got #{other.class}"
        end
      end

      def +(other) = Props.new(merge(other))

      def tags
        return [@parent.tag, @tag] if @parent

        @tag
      end

      def ==(other) = eql?(other)

      def hash = :tag.hash

      def eql?(other) = tags == other.tags

      def call(value)
        raise ArgumentError, 'Expected NOT a hash' if value.is_a?(Hash)
        raise ArgumentError, 'Expected NOT an array' if value.is_a?(Array)

        @validator.call(value)
      end
    end
  end
end
