# frozen_string_literal: true

module Covenant
  module Types
    class BaseProp < BaseType
      def struct
        Types::Struct.new(tag, to_props)
      end

      def to_props
        Types::Props.new([self])
      end

      def name
        tag
      end
    end
  end
end
