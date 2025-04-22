# frozen_string_literal: true

module Covenant
  module Comparable
    class SchemaComparator
      attr_reader :errors

      def initialize(&block)
        @block = block
        @errors = []
      end

      def and_then(other)
        current = self
        Comparable::SchemaComparator.new do |left, right|
          result = []
          result << current.call(left, right)
          result << other.call(left, right)
          result.flatten
        end
      end

      def call(left, right) = @block.call(left, right)
    end
  end
end
