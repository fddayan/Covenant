# frozen_string_literal: true

module Covenant
  module Diff
    class DiffResult
      attr_reader :schema, :errors

      def initialize(schema, errors)
        @schema = schema
        @errors = errors
      end

      def tag = @schema.tag

      def empty? = @errors.empty?

      def success?
        return true if empty?

        case errors
        when Array
          errors.all?(&:success?)
        when String
          errors.empty?
        when DiffResult
          errors.success?
        end
      end

      def failure? = !success?

      def unwrap
        unwrapp_errors.then do |result|
          result.empty? ? result : { tag => result }
        end
      end

      def unwrapp_errors
        return {} if empty?

        case errors
        when DiffResult
          errors.unwrap
        when Array
          errors.map(&:unwrap).reduce({}) do |acc, error|
            acc.merge(error)
          end
        when String
          errors
        else
          raise "Invalid error result type: #{errors.class}"
        end
      end

      def inspect = "DiffResult(#{{ tag => errors }})"

      def to_s = "#{tag} => #{errors}"
    end
  end
end
