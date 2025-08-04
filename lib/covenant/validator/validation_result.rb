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

      def initialize(value, errors = [])
        @value = value
        @errors = errors
      end

      def to_s
        if success?
          "Success(#{@value})"
        else
          "Failure(\n #{value_to_s} => #{@errors.join(', ')})"
          # "Failure(\n\t#{value_to_s})"
        end
      end

      def value_to_s
        if @value.is_a?(Hash)
          @value.map { |k, v| "#{k}: #{v}" }.join("\n\t")
        else
          @value
        end
      end

      def unwrap = _unwrap(value)

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

      def success? = @errors.empty?

      def failure? = !success?

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

      def append_error(error) = ValidationResult.new(@value, @errors + [error])

      def pretty_print(indent = 0)
        if @value.is_a?(Hash)
          pretty_print_hash(@value, indent)
        else
          pretty_print_value(@value, indent)
        end
      end

      private

      def pretty_print_hash(hash, indent = 0)
        lines = []
        prefix = '  ' * indent

        lines << "#{prefix}{".light_black if indent.zero?

        # if hash.empty?
        #   lines << "#{prefix}}".light_black
        #   return lines.join("\n")
        # end

        hash.each do |key, value|
          case value
          when ValidationResult
            if value.success?
              status = '✓'.green
              if value.value.is_a?(Hash)
                lines << "#{prefix}#{key}: #{status}"
                lines << pretty_print_hash(value.value, indent + 1)
              else
                value_str = pretty_print_value(value.value, 0)
                lines << "#{prefix}#{key}: #{status} #{value_str}"
              end
            else
              status = '✗'.red
              error_msg = value.errors.join(', ')
              if value.value.is_a?(Hash)
                lines << "#{prefix}#{key}: #{status} (#{error_msg.red})"
                lines << pretty_print_hash(value.value, indent + 1)
              else
                value_str = pretty_print_value(value.value, 0)
                lines << "#{prefix}#{key}: #{status} #{value_str} (#{error_msg.red})"
              end
            end
          when Hash
            lines << "#{prefix}#{key}:".cyan
            lines << pretty_print_hash(value, indent + 1)
          else
            lines << "#{prefix}#{key}: #{pretty_print_value(value, 0)}"
          end
        end

        lines << "#{prefix}}".light_black if indent.zero?

        lines.join("\n")
      end

      def pretty_print_value(value, indent = 0)
        prefix = '  ' * indent

        case value
        when Hash
          if value.empty?
            '{}'.light_black
          else
            lines = ["#{prefix}{".light_black]
            value.each_with_index do |(k, v), i|
              comma = i < value.size - 1 ? ',' : ''
              lines << "#{prefix}  #{k}: #{pretty_print_value(v, 0)}#{comma}"
            end
            lines << "#{prefix}}".light_black
            lines.join("\n")
          end
        when Array
          if value.empty?
            '[]'.light_black
          else
            "[#{value.map { |v| pretty_print_value(v, 0) }.join(', ')}]"
          end
        when String
          "\"#{value}\"".yellow
        when Integer, Float
          value.to_s.blue
        when TrueClass, FalseClass
          value.to_s.magenta
        when NilClass
          'nil'.light_black
        else
          value.to_s.white
        end
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
