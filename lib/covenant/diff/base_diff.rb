# frozen_string_literal: true

module Covenant
  module Diff
    class BaseDiff
      attr_reader :left, :right, :errors

      def initialize(left, right)
        @left = left
        @right = right
        @errors = []
      end

      protected

      def result(msg) = DiffResult.new(@left, msg)
    end
  end
end
