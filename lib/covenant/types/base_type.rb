# frozen_string_literal: true

module Covenant
  module Types
    class BaseType
      include Taggable

      attr_reader :tag, :parent
      alias name tag

      def initialize(tag, parent = nil)
        tag! tag
        parent! parent if parent
      end

      def ==(other)
        self.class == other.class && tag == other.tag
      end

      def same?(other)
        self == other
      end

      def call(_values)
        raise NotImplementedError, 'You must implement the call method'
      end

      def empty?
        raise NotImplementedError, 'You must implement the call method'
      end

      def compare(other)
        raise NotImplementedError, 'You must implement the compare method'
      end
    end
  end
end
