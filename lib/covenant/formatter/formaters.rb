# frozen_string_literal: true

module Conveant
  module Formatter
    module Formatters
      def call
        Format.new.tap do |format|
          format.instance_eval do
            register_formatter(Covenant::Scalar) do |value|
              "Scalar(#{value.tag}}"
            end
            register_formatter(Props) do |value|
              "Props(#{value.props.map(&:to_s).join(',')})"
            end
            register_formatter(Schema) do |value|
              "Schema(:#{value.tag} => #{value.props})"
            end
            register_formatter(Any) { 'Any' }
            register_formatter(Void) { 'Void' }
          end
        end
        # register_formatter(AnyOf, ->(type) { type.to_s })
        # register_formatter(AllOf, ->(type) { type.to_s })
        # register_formatter(Not, ->(type) { type.to_s })
        # register_formatter(OneOf, ->(type) { type.to_s })
        # register_formatter(NilClass, ->(type) { type.to_s })
        # register_formatter(TrueClass, ->(type) { type.to_s })
        # register_formatter(FalseClass, ->(type) { type.to_s })
      end
    end
  end
end
