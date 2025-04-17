# frozen_string_literal: true

# Validation Monad implementation in Ruby

module Covenant
  module Validator
    # Validator is a blueprint for validation
    class Validator
      include Covenant::Types::Taggable

      def initialize(&validation) = @validation = validation

      def call(value) = @validation.call(value)

      def and_then(other_validator)
        Validator.new do |value|
          result = call(value)
          result.and_then(other_validator)
        end
      end

      def to_s = 'Validator'

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

      def self.any
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
end
