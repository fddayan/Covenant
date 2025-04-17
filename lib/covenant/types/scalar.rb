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

      def +(other)
        case other
        when Scalar, Schema
          Props.new([self, other])
        when Props
          Props.new([self] + other.props)
        end
      end

      def tags
        return [@parent.tag, @tag] if @parent

        @tag
      end

      def ==(other) = eql?(other)

      def hash = :tag.hash

      def eql?(other) = tags == other.tags

      # # (Optional but often recommended) Make == behave the same as eql?
      # def ==(other)
      #   eql?(other)
      # end

      def call(value)
        raise ArgumentError, 'Expected NOT a hash' if value.is_a?(Hash)
        raise ArgumentError, 'Expected NOT an array' if value.is_a?(Array)

        @validator.call(value)
      end
    end
  end
end
