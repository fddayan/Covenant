# frozen_string_literal: true

module Covenant
  module Container
    class CommandResult
      def self.success(result)
        new(result, nil)
      end

      def self.failure(error)
        new(nil, error)
      end

      attr_reader :result, :error

      def initialize(result, error)
        @result = result
        @error = error
      end

      def success? = !error

      def error? = !!error

      def to_s
        if success?
          "Success(#{result})"
        else
          "Failure(#{error})"
        end
      end
    end
  end
end
