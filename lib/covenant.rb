# frozen_string_literal: true

require 'awesome_print'
require 'colorize'
require 'set'
require 'zeitwerk'

loader = Zeitwerk::Loader.for_gem
loader.setup
module Covenant
  class Error < StandardError; end
  class HandlerNotFoundError < Error; end

  class ContractViolation < Error
    attr_reader :errors

    def initialize(errors)
      super(errors.map(&:to_s).join(','))
      @errors = errors
    end
  end

  def self.enable_check_contracts! = @check_contract = true

  def self.disable_check_contracts! = @check_contract = false

  def self.check_contracts? = !!@check_contract

  class System
    def command_registry = @command_registry ||= Container::CommandRegistry.new

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

  def self.Transform(input_schema, output_schema, &) # rubocop:disable Naming/MethodName
    Covenant::Contracts::Transformer.new(input_schema, output_schema, &)
  end

  def self.Scalar(*args) # rubocop:disable Naming/MethodName
    Types::Scalar.new(*args)
  end

  def self.Schema(*args) # rubocop:disable Naming/MethodName
    Types::Schema.new(*args)
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
