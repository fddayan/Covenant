# frozen_string_literal: true

module Covenant
  module Compositions
    class BaseComposition
      include Contracts::Monad

      def self.delegate(*methods, to:)
        methods.each do |method|
          define_method(method) do |*args|
            send(to).public_send(method, *args)
          end
        end
      end

      # def valid? = raise NotImplementedError, 'Subclasses must implement the verify method'

      # def to_s = raise NotImplementedError, 'Subclasses must implement the to_s method'

      def to_instruction
        raise NotImplementedError, 'Subclasses must implement the to_instruction method'
      end
    end
  end
end
