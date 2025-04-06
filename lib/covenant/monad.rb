# frozen_string_literal: true

module Covenant
  module Contracts
    module Monad
      def map(next_contract)
        Map.new(self, next_contract)
      end

      def tee(next_contract)
        Tee.new(self, next_contract)
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
    end
  end
end
