# frozen_string_literal: true

module Covenant
  class CommandLayer
    def initialize
      @handlers = {}
    end

    def register(schema, handler)
      @handlers[schema] = handler
      self
    end

    def handler_for(schema)
      @handlers[schema]
    end
  end

  class CommandRegistry
    def initialize
      @layers = []
    end

    def register_layer(layer)
      @layers << layer
    end

    def handler_for(schema)
      @layers.each do |layer|
        handler = layer.handler_for(schema)
        return handler if handler
      end

      raise HandlerNotFoundError, "No handler found for schema: #{schema.name}"
    end
  end

  class CommandResult
    def self.success(result)
      new(result, nil)
    end

    def self.failure(error)
      new(nil, error)
    end

    attr_reader :result, :error

    def initialize(result, error)
      @result = result
      @error = error
    end

    def success?
      !error
    end

    def error?
      !!error
    end

    def to_s
      if success?
        "Success(#{result})"
      else
        "Failure(#{error})"
      end
    end
  end
end
