# frozen_string_literal: true

module Covenant
  module Comparable
    class StructureComparator
      attr_reader :errors

      def initialize(&block)
        @block = block
        @errors = []
      end

      def and_then(other)
        current = self
        Comparable::StructureComparator.new do |left, right|
          result = []
          result << current.call(left, right)
          result << other.call(left, right)
          result.flatten
        end
      end

      def call(left, right)
        @block.call(left, right)
      end
    end
  end
end
