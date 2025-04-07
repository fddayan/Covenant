# frozen_string_literal: true

require_relative 'type_array'

module Covenant
  module Types
    class Type
      include Taggable

      attr_reader :props, :tag

      def initialize(props)
        raise ArgumentError, 'Expected a hash' unless props.is_a?(Hash)

        @props = props
        tag! props.keys.sort

        # @props.each do |key, value|
        #   # raise ArgumentError, 'Expected a Type' unless value.is_a?(Type)
        #   value.add_tag!(key)
        # end
      end

      def &(other)
        other.map do |props|
          @props.merge(props)
        end
      end

      def size
        first.first.size
      end

      def root
        first.second
      end

      def array(new_key)
        map_first { |_key, value| { new_key => TypeArray.new(value) } }
      end

      def first
        @props.first
      end

      def fmap
        yield @props
      end

      def name
        first.first
      end

      def same?(other)
        TypeCompare.same?(self, other)
      end

      def rename(new_key)
        key, value = first

        Type.new({ new_key => value }).tap { |type| type.retag!([key]) }
      end

      def =~(other)
        return false if other.nil?

        same?(other)
      end

      def [](key)
        @props[key]
      end

      def keys
        @props.keys
      end

      def map_first
        map do |props|
          key, value = props.first
          yield key, value
        end
      end

      def map
        Type.new(yield(@props))
      end

      def call(values)
        unless values.is_a?(Hash) || values.is_a?(Array)
          raise ArgumentError,
                'Expected a hash'
        end

        values.each_with_object({}) do |(key, value), acc|
          type = @props[key]
          acc[key] = type.call(value) unless type.nil?
        end
      end

      def pick(*names)
        map do |props|
          key, value = props.first
          { key => value.slice_props(*names) }
        end
      end

      def slice_props(*names)
        @props.slice(*names)
      end

      def map_slice(*names)
        map do |props|
          props.slice(*names)
        end
      end

      def root?
        @props.size == 1 && @props.keys.first.nil?
      end

      def diff(other)
        return false if other.nil?

        diff = @props.keys - other.keys

        return true if diff.empty?

        @props.slice(*diff)
      end

      def branded
        BrandedType.new(self)
      end

      def to_h
        @props
      end

      def to_s
        @props.to_s
      end
    end
  end
end
