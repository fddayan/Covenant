# frozen_string_literal: true

module Covenant
  class BaseComposition
    include Monad

    def self.delegate(*methods, to:)
      methods.each do |method|
        define_method(method) do |*args|
          send(to).public_send(method, *args)
        end
      end
    end

    def valid?
      raise NotImplementedError, 'Subclasses must implement the verify method'
    end

    def to_s
      raise NotImplementedError, 'Subclasses must implement the to_s method'
    end
  end

  class Map < BaseComposition
    using ColorAliasRefinement
    attr_reader :prev_contract, :next_contract

    delegate :input, to: :prev_contract
    delegate :output, to: :next_contract

    def initialize(prev_contract, next_contract)
      super()
      @prev_contract = prev_contract
      @next_contract = next_contract
    end

    def verify
      @prev_contract.output.same?(@next_contract.input)
    end

    def valid?
      verify.valid?
    end

    def self.format(input, output)
      [
        'Map'.compositon_text,
        '('.symbols_text,
        input.to_s.input_text,
        ' -> '.symbols_text,
        output.to_s.output_text,
        ')'.symbols_text
      ].join
    end

    def to_s
      [
        'Map'.compositon_text,
        '('.symbols_text,
        input.name.to_s.input_text,
        ' -> '.symbols_text,
        output.name.to_s.output_text,
        ', '.symbols_text,
        prev_contract,
        ' => '.compositon_text,
        next_contract,
        ')'.symbols_text
      ].join
    end
  end

  class Tee < BaseComposition
    attr_reader :prev_contract, :next_contract

    delegate :input, :output, to: :prev_contract

    def initialize(prev_contract, next_contract)
      super()
      @prev_contract = prev_contract
      @next_contract = next_contract
      verify
    end

    def verify
      @prev_contract.output.call(@next_contract.input)
    end

    def to_s
      "Tee(#{prev_contract} -> #{next_contract})"
    end
  end

  class OrElse < BaseComposition
    attr_reader :prev_contract, :next_contract

    def initialize(prev_contract, next_contract)
      super()
      @prev_contract = prev_contract
      @next_contract = next_contract
    end

    def verify
      @prev_contract.output.call(@next_contract.input)
    end

    def to_s
      "OrElse(#{prev_contract} -> #{next_contract})"
    end
  end

  class Retry < BaseComposition
    attr_reader :contract, :max_attempts

    delegate :input, :output, to: :contract

    def initialize(contract, max_attempts)
      super()
      @contract = contract
      @max_attempts = max_attempts
    end

    def verify
      @contract.output.call(@contract.input)
    end

    def to_s
      "Retry(#{contract} -> #{max_attempts})"
    end
  end

  class Timeout < BaseComposition
    attr_reader :contract, :seconds

    delegate :input, :output, to: :contract

    def initialize(contract, seconds)
      super()
      @contract = contract
      @seconds = seconds
    end

    def verify
      @contract.output.call(@contract.input)
    end

    def to_s
      "Timeout(#{contract} -> #{seconds})"
    end
  end
end
