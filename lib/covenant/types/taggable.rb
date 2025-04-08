# frozen_string_literal: true

module Covenant
  module Types
    module Taggable
      def tag
        @tag
      end

      def tag!(tag)
        @tag ||= tag
      end

      def parent
        @parent
      end

      def parent!(parent)
        @parent = parent
      end

      def tag_chain
        arr = []
        arr << @tag if @tag
        arr += @parent.tag_chain if @parent
        arr
      end

      protected

      def retag!(tag)
        @tag = tag
      end
    end
  end
end
