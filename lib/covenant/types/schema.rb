# frozen_string_literal: true

module Covenant
  module Types
    class Schema < BaseType
      attr_reader :props

      def initialize(tag, props, parent = nil)
        super(tag, parent, props)
        @props = props.brand_to(self)
        @validator = yield if block_given?
      end

      def zip(*tags) = @props.zip(*tags)

      def brand_to(other_tag) = Schema.new(@tag, @props, other_tag)

      def call(values)
        return Validator::ValidationResult.success(values) if %i[any void].include?(tag)

        props_validation = @props.validate(values)
        _validate_struct(props_validation)
        # @props.validate(values)
      end

      def tags = [@tag, @props.tags]

      def empty? = @props.empty?

      def [](key) = @props[key]

      def ==(other) = compare(other).success?

      def same?(other) = compare(other)

      # def compare(other) = Comparable.check_struct.call(self, other)

      def compare(other) = Covenant::Diff::SchemaDiff.new(self, other).call

      def inspect = "Schema(:#{@tag} => #{@props})"

      def eql?(other)
        return false unless other.is_a?(Schema)

        @tag == other.tag && @props == other.props
      end

      def <=>(other) = compare(other)

      alias satisfies compare

      def -(other)
        case other
        when Scalar, Props
          clone(@props - other)
        when Schema
          @props - other.props
        end
      end

      def +(other)
        case other
        when Scalar, Props
          clone(@props + other)
        when Schema
          new_tag = :"#{@tag}_#{other.tag}"
          Schema.new(new_tag, Props.new([self, other]))
        end
      end

      def clone(props) = Schema.new(@tag, props, @parent)

      def compositions
        @props.props.each_with_object([]) do |prop, acc|
          next unless prop.is_a?(Schema)

          acc << prop
        end
      end

      def to_a = @props.to_a

      def prop?(key) = @props.tag?(key)

      alias tag? prop?

      def keys = @props.keys

      def pick(*tag) = Schema.new(@tag, @props.pick(*tag), @parent)

      def omit(*tags) = Schema.new(@tag, @props.omit(*tags), @parent)

      def size = @props.size

      def to_s = "Struct(:#{@tag} => #{@props})"

      def tag_chain = [props.tag, @tag]

      private

      def _validate_props(values) = @props.validate(values)

      def _validate_struct(props_validation)
        Covenant::Validator::ValidationResult.new(
          props_validation,
          props_validation
            .values
            .flat_map(&:errors)
            .reject(&:empty?)
        )
      end

      def _validate_all = @validator.call(self)
    end

    Any = Scalar.new(:any, :any).struct
    Void = Scalar.new(:void, :void).struct
  end
end
