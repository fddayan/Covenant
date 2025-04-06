# frozen_string_literal: true

module Covenant
  module Types
    module Taggable
      def tag
        @tag
        # ||= self.class.name.split('::').last.downcase
      end

      def tag!(tag)
        # @tag ||= self.class.name.split('::').last.downcase
        @tag ||= tag
      end

      protected

      def retag!(tag)
        @tag = tag
      end
    end
  end
end
