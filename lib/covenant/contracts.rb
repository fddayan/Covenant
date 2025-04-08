# frozen_string_literal: true

module Covenant
  module Contracts
    def self.match(success:, failure:)
      ->(prev) { Match.new(prev, success, failure) }
    end
  end
end
