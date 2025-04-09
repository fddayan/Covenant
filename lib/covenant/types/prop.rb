# frozen_string_literal: true

module Covenant
  module Types
    class BaseProp
      include Taggable

      def initialize(tag, parent = nil)
        tag! tag
        parent! parent if parent
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
    end

    class PropArray < BaseProp
      include Taggable

      def initialize(prop)
        super(:"#{prop.tag}_array", prop.parent)
        @prop = prop
      end

      def call(values)
        raise ArgumentError, 'Expected an array' unless values.is_a?(Array)

        values_validated = transofome_values(values)

        Validator::ValidationResult.new(values_validated,
                                        values_validated
                                        .flat_map(&:errors)
                                        .reject(&:empty?))
      end

      def brand_to(struct)
        PropArray.new(@prop.brand_to(struct))
      end

      private

      def transofome_values(values)
        values.map do |value|
          if value.is_a?(Hash)
            @prop.struct.call(value)
          else
            @prop.call(value)
          end
        end
      end
    end

    # Prop is a blueprint for a property
    class Prop < BaseProp
      include Taggable

      def initialize(tag, validator, parent = nil)
        super(tag, parent)
        @validator = validator
      end

      def brand_to(struct)
        Prop.new(@tag, @validator, struct)
      end

      def array
        PropArray.new(self)
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
