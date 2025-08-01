# frozen_string_literal: true

module Covenant
  module Contracts
    module ClassMethods
      def pipe(*contracts) = Pipe.new(contracts).build

      def match(success:, failure:) = ->(prev) { Match.new(prev, success, failure) }

      def tee(contract) = ->(prev) { Tee.new(prev, contract) }

      def map(contract) = ->(prev) { Map.new(prev, contract) }

      def and_then(contract) = ->(prev) { Map.new(prev, contract) }

      def if_then(condition, contract) = ->(prev) { IfThen.new(prev, condition, contract) }

      def unless_then(condition, contract) = ->(prev) { UnlessThen.new(prev, condition, contract) }
    end

    extend ClassMethods

    def self.included(base)
      base.extend(ClassMethods)
    end
  end
end
