# frozen_string_literal: true

module Covenant
  module Validator
    module Validation # rubocop:disable Metrics/ModuleLength
      # Type coercion
      def self.coerce(type) # rubocop:disable Metrics/AbcSize,Metrics/CyclomaticComplexity,Metrics/MethodLength
        Validator.new do |value| # rubocop:disable Metrics/BlockLength
          case type
          when :integer
            begin
              ValidationResult.new(Integer(value))
            rescue ArgumentError, TypeError
              ValidationResult.new(value,
                                   ["Cannot convert '#{value}' to Integer"])
            end
          when :float
            begin
              ValidationResult.new(Float(value))
            rescue ArgumentError, TypeError
              ValidationResult.new(value,
                                   ["Cannot convert '#{value}' to Float"])
            end
          when :string
            ValidationResult.new(value.to_s)
          when :boolean
            case value.to_s.downcase
            when 'true', 't', 'yes', 'y', '1'
              ValidationResult.new(true)
            when 'false', 'f', 'no', 'n', '0'
              ValidationResult.new(false)
            else
              ValidationResult.new(value,
                                   ["Cannot convert '#{value}' to Boolean"])
            end
          else
            ValidationResult.new(value, ["Unknown type '#{type}' for coercion"])
          end
        end
      end

      # Common validators
      def self.required
        Validator.new do |value|
          if value.nil? || (value.respond_to?(:empty?) && value.empty?)
            ValidationResult.new(value, ['Value is required'])
          else
            ValidationResult.new(value)
          end
        end
      end

      def self.min(minimum)
        Validator.new do |value|
          if value.nil? || value < minimum
            ValidationResult.new(value, ["Value must be at least #{minimum}"])
          else
            ValidationResult.new(value)
          end
        end
      end

      def self.max(maximum)
        Validator.new do |value|
          if value.nil? || value > maximum
            ValidationResult.new(value, ["Value must be at most #{maximum}"])
          else
            ValidationResult.new(value)
          end
        end
      end

      def self.length(min: nil, max: nil) # rubocop:disable Metrics/AbcSize,Metrics/CyclomaticComplexity,Metrics/PerceivedComplexity,Metrics/MethodLength
        Validator.new do |value|
          errors = []

          if !value.nil? && value.respond_to?(:length)
            if min && value.length < min
              errors << "Length must be at least #{min}"
            end

            if max && value.length > max
              errors << "Length must be at most #{max}"
            end
          elsif !value.nil?
            errors << 'Value does not support length validation'
          end

          if errors.empty?
            ValidationResult.new(value)
          else
            ValidationResult.new(value, errors)
          end
        end
      end

      def self.format(pattern)
        Validator.new do |value|
          if value.nil? || !pattern.match?(value.to_s)
            ValidationResult.new(value,
                                 ['Value does not match required format'])
          else
            ValidationResult.new(value)
          end
        end
      end

      def self.custom
        Validator.new do |value|
          result, error = yield(value)
          if result
            ValidationResult.new(value)
          else
            ValidationResult.new(value, [error])
          end
        end
      end
    end
  end
end
