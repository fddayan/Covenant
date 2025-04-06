# frozen_string_literal: true

require_relative 'type_array'

module Covenant
  class Type
    include Covenant::Taggable

    attr_reader :props, :tag

    def initialize(props)
      raise ArgumentError, 'Expected a hash' unless props.is_a?(Hash)

      # if props.size != 1
      #   raise ArgumentError,
      #         "Expected a hash with one key #{props}"
      # end

      # if props.keys.first.nil?
      #   raise ArgumentError,
      #         'Expected a hash with one key'
      # end
      # if props.values.first.nil?
      #   raise ArgumentError,
      #         'Expected a hash with one key'
      # end

      @props = props
      tag!(props.keys.first)
    end

    def &(other)
      other.map do |props|
        @props.merge(props)
      end
    end

    def array(new_key)
      map_first do |_key, value|
        { new_key => TypeArray.new(value) }
      end
    end

    def first
      @props.first
    end

    def fmap
      yield @props
    end

    # def match?
    # end

    def same?(other)
      tag == other.tag
    end

    def rename(new_key)
      key, value = first

      Type.new({ new_key => value }).tap do |type|
        type.retag!(key)
      end
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
        { key => value.slice(*names) }
      end
    end

    def slice(*names)
      @props.slice(*names)
    end

    def root?
      @props.size == 1 && @props.keys.first.nil?
    end

    def to_s
      @props.to_s
    end
  end
end
