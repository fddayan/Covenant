# frozen_string_literal: true

module Covenant
  module Ast
    class AstCheckError
      attr_reader :errors

      def initialize(errors) = @errors = errors

      def empty?
        return true if @errors.nil? || @errors.empty?

        @errors.all? do |error|
          error.is_a?(Hash) && error.values.all? { |v| v.nil? || v.empty? }
        end
      end

      def to_s = errors.to_s

      # private

      # def error_to_sentence(error, path)
      #   if error.is_a?(Hash)
      #     error.filter_map do |k, v|
      #       next nil if v.nil? || v.empty?

      #       "#{path}#{k}: #{v.join(', ')}"
      #     end
      #   else
      #     key, value = error
      #     return nil if value.nil? || value.empty?

      #     errors_to_sentences(value, "#{path}#{key}.")
      #   end
      # end
    end
  end
end
