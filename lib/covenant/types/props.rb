# frozen_string_literal: true

module Covenant
  module Types
    class Props
      include Taggable

      attr_reader :props

      def initialize(props, parent = nil)
        tag! props.map(&:tag)
        if parent
          parent! parent
          @props = props.map { |prop| prop.brand_to(parent) }
        else
          @props = props
        end
      end

      def brand_to(struct)
        Props.new(@props, struct)
      end

      def +(other)
        case other
        when Prop, Struct
          Props.new(props + [other])
        when Props
          Props.new(props + other.props)
        end
      end

      def reject(tags)
        Props.new(@props.reject { |r| tags.include?(r.tag) })
      end

      def -(other)
        case other
        when Prop
          reject [other.tag]
        when Props
          reject other.props.map(&:tag)
        else
          raise ArgumentError, "Expected Prop, Struct or Props got #{other.class}"
        end
      end

      def [](key)
        props_map[key]
      end

      def key?(key)
        props_map.key?(key)
      end

      def to_a
        @props
      end

      def keys
        @props.map(&:tag)
      end

      def empty?
        @props.empty?
      end

      def struct_props
        @struct_props ||= @props.select { |prop| prop.is_a?(Struct) }
      end

      def prop_props
        @prop_props ||= @props.select { |prop| prop.is_a?(Prop) }
      end

      def size
        @props.size
      end

      def to_s
        "Props[#{@props.map(&:to_s).join(', ')}]"
      end

      def props_map
        @props_map ||= @props.to_h { |prop| [prop.tag, prop] }
      end
    end
  end
end
