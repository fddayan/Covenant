# frozen_string_literal: true

module Covenant
  module Comparable
    class PropsComparator
      def initialize(left, right)
        @left = left
        @right = right
        @errors = []
      end

      def call
        @left.props.filter_map do |left_prop|
          next if @right.include?(left_prop.tag)

          Result.failure(left_prop.tag, 'missing')
        end
      end

      # def and_then(other)
      #   current = self
      #   Comparable::PropsComparator.new do |left, right|
      #     result = []
      #     result << current.call(left, right)
      #     result << other.call(left, right)
      #     result.flatten
      #   end
      # end
    end
  end
end
