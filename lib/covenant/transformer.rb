# frozen_string_literal: true

module Covenant
  class Transformer
    # include Dry::Monads[:result]

    attr_reader :input_schema, :output_schema, :block

    def initialize(input_schema, output_schema, &block)
      @input_schema = input_schema
      @output_schema = output_schema
      @block = block
    end

    def call(input)
      result = input_schema.call(input)

      if result.success?
        output = block.call(result.to_h)
        output_result = output_schema.call(output)

        if output_result.success?
          Result.success(output_result.to_h)
        else
          Result.failure(output_result.errors.to_h)
        end
      else
        Result.failure(result.errors.to_h)
      end
    end
  end
end
