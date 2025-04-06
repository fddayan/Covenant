# frozen_string_literal: true

module Covenant
  module Types
    class TypeArray
      def initialize(type)
        @type = type
      end

      def name
        @type.name
      end

      def map(&block)
        @type.map(&block)
      end

      def call(array)
        raise ArgumentError, 'Expected an array' unless array.is_a?(Array)

        array.map { |item| @type.call(item) }
      end

      def to_s
        "#{@type}[]"
      end
    end
  end
end
