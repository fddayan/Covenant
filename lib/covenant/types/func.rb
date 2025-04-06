# frozen_string_literal: true

module Covenant
  class Func
    include Covenant::Taggable

    attr_reader :props, :tag

    def initialize(name, input_type, output_type)
      raise ArgumentError, 'Expected a name' unless name.is_a?(Symbol)
      raise ArgumentError, 'Expected a Type' unless input_type.is_a?(Type)
      raise ArgumentError, 'Expected a Type' unless output_type.is_a?(Type)

      @name = name
      @input_type = input_type
      @output_type = output_type
      tag!(name)
    end

    def call(args)
      raise ArgumentError, 'Expected an array' unless args.is_a?(Array)

      @props.values.first.call(*args)
    end

    def to_s
      "#{tag} -> #{props.values.first}"
    end
  end
end
