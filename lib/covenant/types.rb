# frozen_string_literal: true

require 'covenant/types/type'
require 'covenant/types/type_array'

module Covenant
  # This file serves as the entry point for types

  def self.Type(args) # rubocop:disable Naming/MethodName
    Type.new(args)
  end
end
