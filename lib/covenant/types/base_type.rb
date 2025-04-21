# frozen_string_literal: true

module Covenant
  module Types
    class Tag
      attr_reader :tag, :parent, :child
      alias name tag

      def initialize(tag, parent, _child)
        @tag = tag
        @parent = parent
        # @child = child
      end

      # def tags_upstream
      #   arr = []
      #   arr << @tag
      #   arr += @parent.tags_upstream if @parent
      #   arr
      # end

      # def tags_downstream
      #   arr = []
      #   arr << @tag
      #   if @child
      #     arr += @child.is_a?(Array) ? @child.map(&:tags_downstream) : @child.tags_downstream
      #   end
      #   arr
      # end

      # def tags_chain
      #   arr = []
      #   arr << @tag
      #   arr += @parent.tags_upstream if @parent
      #   arr += @child.tags_downstream if @child
      #   arr
      # end
    end

    class BaseType < Tag
      attr_reader :tag, :parent
      alias name tag

      def initialize(tag, parent, child = nil) = super

      def ==(other) = self.class == other.class && tag == other.tag

      def same?(other) = self == other

      def call(_values) = raise NotImplementedError, 'You must implement the call method'

      def empty? = raise NotImplementedError, 'You must implement the call method'

      def compare(other) = raise NotImplementedError, 'You must implement the compare method'
    end
  end
end
