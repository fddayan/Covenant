# frozen_string_literal: true

require 'dry-schema'
require 'awesome_print'
require 'colorize'
require 'zeitwerk'

# Zeitwerk::Loader.for_gem.setup

# require 'covenant/version'
# require 'covenant/monad'
# require 'covenant/color_alias_refinment'
# require 'covenant/command'
# require 'covenant/runner'
# require 'covenant/compositions'
# require 'covenant/contract'
# require 'covenant/transformer'
# require 'covenant/schemas'
# require 'covenant/validator'
# require 'covenant/ast/ast'
# require 'covenant/ast/ast_visitor'
# require 'covenant/ast/ast_short_printer'
# require 'covenant/ast/ast_three_printer'
# require 'covenant/types/taggable'
# require 'covenant/types/type'

loader = Zeitwerk::Loader.for_gem
loader.setup

# String = Covenant::Schema.pure(:string)
# Integer = Covenant::Schema.pure(:string)

# # Covenant.pipe(
# User = Covenant::Schema.prop(:name,     String)   +
#        Covenant::Schema.prop(:age,      Integer)  +
#        Covenant::Schema.prop(:email,    String)   +
#        Covenant::Schema.prop(:address,  String)   +
#        Covenant::Schema.prop(:phone,    String)

# Payload = Covenant::Schema.prop(:user, User.branded.pick(:name, :email))

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

  def self.Schema(name, &block) # rubocop:disable Naming/MethodName
    Covenant::Schemas::Schema.new(name, &block)
  end

  def self.Type(args) # rubocop:disable Naming/MethodName
    Types::Type.new(args)
  end

  def self.Prop(*args) # rubocop:disable Naming/MethodName
    Types::Prop.new(*args)
  end

  def self.Struct(*args) # rubocop:disable Naming/MethodName
    Types::Struct.new(*args)
  end

  def self.assert_type(value, type)
    return if value.is_a?(type)

    raise ArgumentError,
          "Expected type #{type}, got #{value.class}"
  end
end
