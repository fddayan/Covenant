# frozen_string_literal: true

module Covenant
  class Contract
    include Monad
    using ColorAliasRefinement

    attr_reader :command, :input, :output

    def initialize(command, input, output)
      @command = command
      @input = input
      @output = output
    end

    def self.format(input, command, output)
      [
        'Contract'.contract_text,
        '('.symbols_text,
        input.to_s.input_text,
        ' -> '.symbols_text,
        command.to_s.command_text,
        ' -> '.symbols_text,
        output.to_s.output_text,
        ')'.symbols_text
      ].join
    end

    def to_s
      [
        'Contract'.contract_text,
        '('.symbols_text,
        input.name.to_s.input_text,
        ' -> '.symbols_text,
        command.to_s.command_text,
        ' -> '.symbols_text,
        output.name.to_s.output_text,
        ')'.symbols_text
      ].join
    end
  end
end
