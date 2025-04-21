# frozen_string_literal: true

module Covenant
  module Formatter
    class Format
      def initialize = @formatters = {}

      def register_formater(type, &block) = @formatters[type.to_s] = block

      def [](type) = @formatters[type.class.to_s] || (raise "Formatter not found for type: #{type}")

      def fromat(type) = self[type].call(type)
    end
  end
end
