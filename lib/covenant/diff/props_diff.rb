# frozen_string_literal: true

module Covenant
  module Diff
    class PropsDiff < BaseDiff
      def call = result(diff_props(left, right))

      def diff_props(left, right)
        left.zip(right).filter_map do |left_prop, right_prop|
          diff_prop(left_prop, right_prop)
        end
      end

      def diff_prop(left, right)
        case left
        when Types::Scalar
          ScalarDiff.new(left, right).call
        when Types::Schema
          SchemaDiff.new(left, right).call
        end
      end
    end
  end
end
