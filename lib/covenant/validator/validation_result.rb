# frozen_string_literal: true

module Covenant
  module Validator
    class ValidationResult
      attr_reader :value, :errors

      def self.success(value)
        ValidationResult.new(value)
      end

      def self.failure(errors)
        ValidationResult.new(nil, errors)
      end

      # Initialize with value and optional errors

      def initialize(value, errors = [])
        @value = value
        @errors = errors
      end

      def to_s
        if success?
          "Success(#{@value})"
        else
          "Failure('#{@value}' => #{@errors.join(', ')})"
        end
      end

      def unwrap
        _unwrap(value)
      end

      def _unwrap(val)
        case val
        when Hash
          val.transform_values do |v|
            _unwrap(v)
          end
        when Array
          val.map do |v|
            _unwrap(v)
          end
        when ValidationResult
          _unwrap(val.value)
        else
          val
        end
      end

      def success?
        @errors.empty?
      end

      def failure?
        !success?
      end

      def and_then(validator)
        if failure?
          # Don't short-circuit, run the next validator and merge errors
          next_result = validator.call(@value)
          ValidationResult.new(next_result.value,
                               @errors + next_result.errors)
        else
          validator.call(@value)
        end
      end

      def map(func)
        return self if failure?

        ValidationResult.new(func.call(@value), @errors)
      end

      def append_error(error)
        ValidationResult.new(@value, @errors + [error])
      end

      # Helper method to merge results
      def self.merge(results)
        all_errors = results.flat_map(&:errors)

        # If no errors, return the last valid result
        if all_errors.empty?
          results.last
        else
          # Return last value with all errors accumulated
          last_value = results.find(&:success?)&.value || results.last.value
          ValidationResult.new(last_value, all_errors.uniq)
        end
      end
    end
  end
end
