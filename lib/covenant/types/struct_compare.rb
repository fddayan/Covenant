# frozen_string_literal: true

module Covenant
  module Types
    class StructCompare
      attr_reader :errors

      def initialize(struct_a, struct_b)
        unless struct_a.is_a?(Struct) && struct_b.is_a?(Struct)
          raise ArgumentError,
                "Expected Struct and got #{struct_a.class} and #{struct_b.class}"
        end

        @struct_a = struct_a
        @struct_b = struct_b
        @errors = []
        compare!
      end

      def tag
        @struct_a.tag
      end

      def success?
        @errors.empty?
      end

      def failure?
        !success?
      end

      protected

      def compare!
        add_error("Struct tags are not the same #{@struct_a.tag} != #{@struct_b.tag}") do
          @struct_a.tag != @struct_b.tag
        end

        struct_diff = @struct_b - @struct_a

        add_error("Missing props: #{struct_diff.keys.join(', ')}") do
          !struct_diff.empty?
        end

        compositions_struct_compare.each do |struct_compare|
          add_nested_struct_compare(struct_compare) { struct_compare.failure? }
        end
      end

      def add_nested_struct_compare(struct_compare)
        @errors << { struct_compare.tag => struct_compare.errors } if yield
      end

      def add_error(error)
        @errors << error if yield
      end

      def compositions_struct_compare
        @struct_a.compositions.filter_map do |a|
          b = @struct_b.compositions.detect { |c2| a.tag == c2.tag }

          next if b.nil?

          StructCompare.new(a, b)
        end
      end
    end
  end
end
