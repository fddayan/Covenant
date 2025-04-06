# frozen_string_literal: true

# Validation Monad implementation in Ruby

module Covenant
  # Validation Monad implementation in Ruby

  # ValidationResult represents the outcome of validation
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
        ValidationResult.new(next_result.value, @errors + next_result.errors)
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

  # Validator is a blueprint for validation
  class Validator
    def initialize(&validation)
      @validation = validation
    end

    def call(value)
      @validation.call(value)
    end

    def and_then(other_validator)
      Validator.new do |value|
        result = call(value)
        result.and_then(other_validator)
      end
    end

    # Chain multiple validators and run all of them regardless of failures
    def self.chain(*validators)
      Validator.new do |value|
        results = []
        current_value = value

        validators.each do |validator|
          result = validator.call(current_value)
          results << result
          # Update the current value if this validation was successful
          current_value = result.value if result.success?
        end

        Result.merge(results)
      end
    end

    def self.empty
      Validator.new do |value|
        ValidationResult.new(value)
      end
    end

    # Combine multiple validators
    def self.all(*validators)
      Validator.new do |value|
        results = validators.map { |v| v.call(value) }
        ValidationResult.merge(results)
      end
    end
  end

  # Validation DSL for creating common validators
  module Validation
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
            ValidationResult.new(value, ["Cannot convert '#{value}' to Float"])
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

    def self.length(min: nil, max: nil) # rubocop:disable Metrics/AbcSize,Metrics/CyclomaticComplexity,Metrics/MethodLength,Metrics/PerceivedComplexity
      Validator.new do |value|
        errors = []

        if !value.nil? && value.respond_to?(:length)
          if min && value.length < min
            errors << "Length must be at least #{min}"
          end

          errors << "Length must be at most #{max}" if max && value.length > max
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
          ValidationResult.new(value, ['Value does not match required format'])
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

  # Example of usage:
  # # Define age validator blueprint
  # age_validator = Validation.coerce(:integer)
  #   .and_then(Validation.min(0))
  #   .and_then(Validation.max(120))
  #
  # Apply validation
  # result = age_validator.call("25")
  # if result.success?
  #   puts "Valid age: #{result.value}"
  # else
  #   puts "Validation failed: #{result.errors.join(', ')}"
  # end
  #
  # Complex validation with multiple fields
  # email_validator = Validation.required
  #   .and_then(Validation.format(/\A[^@\s]+@[^@\s]+\.[^@\s]+\z/))
  #   .and_then(Validation.length(max: 100))
  #
  # Multiple validations in parallel
  # combined_validator = Validator.all(
  #   Validation.required,
  #   Validation.length(min: 3, max: 50),
  #   Validation.format(/\A[a-zA-Z0-9]+\z/)
  # )
  #
  # Validate a string
  # result = combined_validator.call("user123")
end
