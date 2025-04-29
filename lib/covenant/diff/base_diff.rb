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

      def result_success = DiffResult.new(@left, '')
    end
  end
end
