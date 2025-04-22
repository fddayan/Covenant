# frozen_string_literal: true

module Covenant
  module Diff
    class ScalarDiff < BaseDiff
      def call
        return result('missing') if @right.nil?
        return result('different tags') if @left.tag != @right.tag
        return result('missing') if @left.nil?

        result('missing') if @right.nil?
      end
    end
  end
end
