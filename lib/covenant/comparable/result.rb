# frozen_string_literal: true

module Covenant
  module Comparable
    class Result
      attr_reader :errors, :tag

      # def self.merge_all(struct_comparrator_results)
      #   struct_comparrator_results.reduce(nil) do |result, acc|
      #     if result.nil?
      #       acc
      #     elsif result.success && acc.success
      #       StructureComparatorResult.new(
      #         result.tag,
      #         result.success && acc.success,
      #         StructureComparatorResult.merge_errors(result.errors, acc.errors)
      #       )
      #     else
      #       StructureComparatorResult.new(
      #         result.tag,
      #         false,
      #         StructureComparatorResult.merge_errors(result.errors, acc.errors)
      #       )
      #     end
      #   end
      # end

      def self.success(tag)
        new(tag, nil)
      end

      def self.failure(tag, errors)
        new(tag, errors.is_a?(Array) ? errors : [errors])
      end

      def self.from_array(tag) = Result.new(tag, yield.reject(&:success?))

      def to_arr = [@tag, self]

      def self.from_result(result)
        return result if result.is_a?(Result)

        if result.is_a?(Hash)
          return Result.new(
            result.fetch(:tag),
            result.fetch(:success),
            result.fetch(:errors)
          )
        end

        raise ArgumentError,
              'Expected StructureComparatorResult or Hash'
      end

      def initialize(tag, errors)
        @tag = tag
        # @success = success
        @errors = errors == false ? nil : errors
      end

      def to_s = "#{self.class} tag:#{@tag} errors:#{@errors}"

      def unwrap
        return {} if @errors.nil? || @errors.empty?

        vals = @errors.each_with_object({}) do |e, acc|
          next if e.nil?
          next if e.is_a?(Result) && e.success?

          acc[e.tag] = e.unwrap
        end

        { @tag => vals }
      end

      def success? = !failure?

      def failure?
        return false if @errors.nil?
        return false if @errors.is_a?(Array) && @errors.empty?

        @errors.any? do |e|
          e.is_a?(Result) ? e.failure? : !e.nil?
        end
      end

      def to_h = { success: @success, errors: @errors }
    end
  end
end
