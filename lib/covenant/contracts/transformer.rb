# frozen_string_literal: true

module Covenant
  module Contracts
    class Transformer < BaseComposition
      attr_reader :input_schema, :output_schema, :block, :prev_contract

      delegate :output, to: :next_contract

      alias input input_schema

      def initialize(prev_contract, input_schema, output_schema, &block)
        super()
        @prev_contract = prev_contract
        @input_schema = input_schema
        @output_schema = output_schema
        @block = block
      end

      def call(input)
        return input if input.is_a?(Runtime::ExecutionResult) && input.failure?

        input_schema_result = @input_schema.call(input.unwrap)

        if input_schema_result.failure?
          return Runtime::ExecutionResult.new(
            self,
            self,
            input_schema_result,
            nil
          )
        end

        next_input = @block.call(input.unwrap)

        output_schema_result = @output_schema.call(next_input)

        puts output_schema_result

        # if output_schema_result.failure?
        #   return Runtime::ExecutionResult.new(
        #     self,
        #     self,
        #     input_schema_result,
        #     output_schema_result
        #   )
        # end

        Runtime::ExecutionResult.new(self, self, input_schema_result, output_schema_result)
      end

      def to_s = 'Transformer'

      def command = 'Transformer'

      # def call(input)
      #   input_result = input_schema.call(input)

      #   if input_result.failure?
      #     return Runtime::ExecutionResult.new(contract, self, input_result,
      #                                         nil)
      #   end

      #   transformed_result = block.call(input_result.unwrap)
      #   output_result = contract.output.call(transformed_result)

      #   if output_result.success?
      #     Runtime::ExecutionResult.new(contract, self, input_result, output_result)
      #   else
      #     Runtime::ExecutionResult.new(contract, self, input_result, output_result)
      #   end
      # end

      # attr_reader :input_schema, :output_schema, :block

      # def initialize(input_schema, output_schema, &block)
      #   @input_schema = input_schema
      #   @output_schema = output_schema
      #   @block = block
      # end

      # def call(input)
      #   result = input_schema.call(input)

      #   Result.failure(result.errors.to_h) unless result.success?
      #   output = block.call(result.to_h)
      #   output_result = output_schema.call(output)

      #   if output_result.success?
      #     Result.success(output_result.to_h)
      #   else
      #     Result.failure(output_result.errors.to_h)
      #   end
      # end
    end
  end
end
