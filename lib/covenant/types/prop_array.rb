# frozen_string_literal: true

module Covenant
  module Types
    # PropArray is a class that represents an array of properties.
    # It includes the Taggable module for tagging functionality.
    # It also includes the StructCompare module for comparing structures.
    class PropArray < BaseProp
      include Taggable

      def initialize(prop)
        super(:"#{prop.tag}_array", prop.parent)
        @prop = prop
      end

      def call(values)
        raise ArgumentError, 'Expected an array' unless values.is_a?(Array)

        values_validated = transofome_values(values)

        Validator::ValidationResult.new(
          values_validated,
          values_validated
          .flat_map(&:errors)
          .reject(&:empty?)
        )
      end

      def brand_to(struct) = PropArray.new(@prop.brand_to(struct))

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
  end
end
