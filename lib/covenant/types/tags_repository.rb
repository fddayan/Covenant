# frozen_string_literal: true

module Covenant
  module Types
    class TagAlreadyDefinedError < StandardError; end

    class TagsRepository
      def initialize(name)
        @name = name
        @tags = {}
      end

      def add(tag, type)
        raise TagAlreadyDefinedError, "Tag '#{tag}' is already defined" if @tags.key?(tag)
        raise ArgumentError, "Tag '#{tag}' must be a symbol" unless tag.is_a?(Symbol)

        @tags[tag] = type
      end

      def get(tag)
        @tags[tag]
      end

      def tag?(tag)
        @tags.key?(tag)
      end
    end
  end
end
