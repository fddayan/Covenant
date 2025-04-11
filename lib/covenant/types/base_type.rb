# frozen_string_literal: true

module Covenant
  module Types
    class Tag
      attr_reader :tag, :parent, :child
      alias name tag

      def initialize(tag, parent, child)
        @tag = tag
        @parent = parent
        @child = child
      end

      def tags_upstream
        arr = []
        arr << @tag
        arr += @parent.tag_upstream if @parent
        arr
      end

      def tags_downstream
        arr = []
        arr << @tag
        arr += @child.tag_downstream if @child
        arr
      end
    end

    class BaseType < Tag
      # include Taggable

      attr_reader :tag, :parent
      alias name tag

      def initialize(tag, parent)
        super(tag, parent, nil)
        # tag! tag
        # parent! parent if parent
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
