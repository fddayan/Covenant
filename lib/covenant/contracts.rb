# frozen_string_literal: true

module Covenant
  module Contracts
    def self.pipe(*contracts)
      Pipe.new(contracts).build
    end

    def self.match(success:, failure:)
      ->(prev) { Match.new(prev, success, failure) }
    end

    def self.tee(contract)
      ->(prev) { Tee.new(prev, contract) }
    end
  end
end
