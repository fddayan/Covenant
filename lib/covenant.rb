# frozen_string_literal: true

require 'awesome_print'
require 'colorize'
require 'zeitwerk'

loader = Zeitwerk::Loader.for_gem
loader.setup
module Covenant
  class Error < StandardError; end
  class HandlerNotFoundError < Error; end

  class System
    def command_registry
      @command_registry ||= Container::CommandRegistry.new
    end

    def layer
      layer = Container::CommandLayer.new
      yield(layer)
      add_layer(layer)
      self
    end

    def add_layer(layer)
      unless layer.is_a?(Container::CommandLayer)
        raise ArgumentError,
              "Expected CommandLayer, got #{layer.class}"
      end

      command_registry.register_layer(layer)

      self
    end

    def call(contract, input)
      raise 'No command registry found' unless @command_registry

      Runtime::Runner.new(@command_registry).call(contract, input)
    end
  end

  def self.Layer # rubocop:disable Naming/MethodName
    layer = Container::CommandLayer.new
    yield(layer)
    layer
  end

  def self.Runtime(*layers) # rubocop:disable Naming/MethodName
    System.new.tap do |system|
      layers.each do |layer|
        system.add_layer(layer)
      end
    end
  end

  def self.layer
    Container::CommandLayer.new
  end

  def self.runtime
    System.new
  end

  def self.run(layer, command)
    raise 'No command registry found' unless layer
    raise 'No command found' unless command

    runtime.add_layer(layer).call(command)
  end

  def self.Contract(*args) # rubocop:disable Naming/MethodName
    Covenant::Contracts::Contract.new(*args)
  end

  def self.transformer(input_schema, output_schema, &block)
    Covenant::Contracts::Transformer.new(input_schema, output_schema, &block)
  end

  def self.Prop(*args) # rubocop:disable Naming/MethodName
    Types::Prop.new(*args)
  end

  def self.Struct(*args) # rubocop:disable Naming/MethodName
    Types::Struct.new(*args)
  end

  def self.Validate # rubocop:disable Naming/MethodName
    Covenant::Validator::Validation
  end

  def self.assert_type(value, type)
    return if value.is_a?(type)

    raise ArgumentError,
          "Expected type #{type}, got #{value.class}"
  end

  def self.assert_any_type_of(value, types)
    return if types.any? { |type| value.is_a?(type) }

    raise ArgumentError,
          "Expected one of types #{types}, got #{value.class}"
  end
end
