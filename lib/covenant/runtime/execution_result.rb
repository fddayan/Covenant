# frozen_string_literal: true

module Covenant
  module Runtime
    class ExecutionResult
      attr_reader :contract, :handler, :input_validation_result, :output_validation_result

      def initialize(contract, handler, input_validation_result, output_validation_result = nil)
        @contract = contract
        @handler = handler
        @input_validation_result = input_validation_result
        @output_validation_result = output_validation_result
      end

      def self.value(input)
        input.is_a?(ExecutionResult) ? input.value : input
      end

      def value
        @output_validation_result.value
      end

      def success?
        input_success? && output_success?
      end

      def input_success?
        @input_validation_result.success?
      end

      def output_success?
        @output_validation_result.success?
      end

      def failure?
        !success?
      end

      def blame
        return if success?

        from = @input_validation_result.failure? ? 'input' : 'output'

        [
          @handler.to_s.red,
          'failed to validate'.magenta,
          from.red,
          'for'.magenta,
          @contract.command.to_s.red,
          'with'.magenta,
          errors.join(', ').red
        ].join(' ')
        # "#{@handler} did not follow #{from} contract #{@contract.command}"
      end

      def unwrap
        return @output_validation_result.unwrap if success?

        raise 'Cannot unwrap a failed result'
      end

      def errors
        @output_validation_result.errors + @input_validation_result.errors
      end
    end
  end
end
