# frozen_string_literal: true

module Covenant
  module Types
    class TypeCompare
      attr_reader :type_a, :type_b, :errors

      def self.same?(type_a, type_b)
        errors = []
        if type_a.tag != type_b.tag
          errors << "Types tags are not the same: #{type_a.tag} => #{type_b.tag}"
          # elsif type_a.size != type_b.size
          #   errors << "Types props are not the same: #{type_a.size} => #{type_b.size}"
        end

        new(type_a, type_b, errors)
      end

      def initialize(type_a, type_b, errors = [])
        @type_a = type_a
        @type_b = type_b
        @errors = errors
      end

      def success?
        @errors.empty?
      end

      def failure?
        !success?
      end
    end
  end
end
