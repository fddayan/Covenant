# frozen_string_literal: true

module Covenant
  module Types
    class BaseProp < BaseType
      def struct = Types::Schema.new(tag, to_props)

      def to_props = Types::Props.new([self])

      def name = tag
    end
  end
end
