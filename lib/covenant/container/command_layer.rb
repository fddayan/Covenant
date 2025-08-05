# frozen_string_literal: true

module Covenant
  module Container
    class RunnableContract
      attr_reader :contract, :layer

      def initialize(contract, layer)
        @contract = contract
        @layer = layer
      end

      def handler_for(tag)
        @layer.handler_for(tag) || raise("No handler found for contract #{tag} in layer #{@layer}")
      end

      def handler
        case @contract
        when Contracts::SimpleContract
          hand = handler_for(@contract.tag)
          ->(args) { hand.call(args) }
        when Contracts::ComposableContract
          runnable_contract_requirements = @contract.contracts.to_h do |c|
            [c.tag, RunnableContract.new(c, @layer)]
          end

          ->(args) { @contract.block.call(runnable_contract_requirements, args) }
        when RunnableContract
          combined_layer = CommandLayer.merge(@contract.layer, @layer)
          runnable = RunnableContract.new(@contract.contract, combined_layer)

          ->(args) { runnable.call(args) }
        else
          raise "Unknown contract type: #{@contract.class}"
        end
      end

      def tag = @contract.tag

      def input = @contract.input

      def output = @contract.output

      def call(args)
        check_requirements!
        pipe(
          Validator::ValidationResult.success(args),
          @contract.input,
          handler,
          @contract.output
        )
      end

      def check_requirements!
        missing = requirements - requirements_provided
        raise "Missing requirements: #{missing.join(', ')}" if missing.any?
      end

      def requirements_provided = @contract.requirements & @layer.handler_names

      def requirements = @contract.requirements - @layer.handler_names

      def pipe(*args)
        initial = args.shift
        args.reduce(initial) do |acc, step|
          case acc
          when Validator::ValidationResult
            break acc if acc.failure?

            step.call(acc.unwrap) if step.respond_to?(:call)
          else
            step.call(acc) if step.respond_to?(:call)
          end
        end
      end
    end

    class CommandLayer
      def self.merge(*args)
        args.each_with_object(new) do |arg, layer|
          layer.merge!(arg)
        end
      end

      # def self.provide(layer, contract)
      # end

      attr_reader :handlers

      def initialize(handlers = {}) = @handlers = handlers

      def register(schema, handler)
        @handlers[schema] = handler
        self
      end

      def provide(contract) = RunnableContract.new(contract, self)

      def handler_names = @handlers.keys

      def handler?(schema) = @handlers.key?(schema)

      def handler_for(schema) = @handlers[schema]

      def merge(other_layer) = CommandLayer.new(@handlers.merge(other_layer.handlers))

      def merge!(other_layer)
        @handlers.merge!(other_layer.handlers)
        self
      end

      def <<(handler)
        @handlers[handler.tag] = handler
        self
      end
    end
  end
end
