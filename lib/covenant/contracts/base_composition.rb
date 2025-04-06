# frozen_string_literal: true

module Covenant
  module Contracts
    class BaseComposition
      include Monad

      def self.delegate(*methods, to:)
        methods.each do |method|
          define_method(method) do |*args|
            send(to).public_send(method, *args)
          end
        end
      end

      def valid?
        raise NotImplementedError, 'Subclasses must implement the verify method'
      end

      def to_s
        raise NotImplementedError, 'Subclasses must implement the to_s method'
      end
    end
  end
end
