# frozen_string_literal: true

module Covenant
  module Contracts
    module Monad
      def map(next_contract)
        if next_contract.is_a?(Proc)
          Map.new(self, next_contract.call(self))
        else
          Map.new(self, next_contract)
        end
      end

      def tee(next_contract)
        if next_contract.is_a?(Proc)
          Tee.new(self, next_contract.call(self))
        else
          Tee.new(self, next_contract)
        end
      end

      def transform(input_schema, output_schema, &block)
        Transformer.new(self, input_schema, output_schema, &block)
      end

      def or_else(next_contract)
        OrElse.new(self, next_contract)
      end

      def retry(max_attempts)
        Retry.new(self, max_attempts)
      end

      def timeout(seconds)
        Timeout.new(self, seconds)
      end

      def match(success:, failure:)
        Match.new(self, success, failure)
      end

      alias and_then map
    end
  end
end
