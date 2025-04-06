# frozen_string_literal: true

module Covenant
  class AstVisitor
    using ColorAliasRefinement

    def initialize(ast)
      @ast = ast
    end

    def print
      print_ast(@ast)
    end

    def puts_indent(indent, text_or_arr)
      text = text_or_arr.is_a?(Array) ? text_or_arr.join : text_or_arr
      puts "#{' ' * indent}#{text}"
    end

    def indent_text(indent, text)
      "#{' ' * indent}#{text}"
    end

    def print_ast(node, indent = 0) # rubocop:disable Metrics/AbcSize,Metrics/MethodLength
      case node[:type]
      when :contract
        print_contract(node, indent)
      when :map
        print_map(node, indent)
        print_ast(node[:prev_contract], indent + 2)
        # print_map_contract_separator(indent + 2)
        print_ast(node[:next_contract], indent + 2)
      when :tee
        print_tee(node, indent)
        print_ast(node[:prev_contract], indent + 2)
        print_ast(node[:next_contract], indent + 2)
      when :or_else
        print_or_else(node, indent)
        print_ast(node[:prev_contract], indent + 2)
        print_ast(node[:next_contract], indent + 2)
      when :retry
        print_retry(node, indent)
        print_ast(node[:contract], indent + 2)
      when :timeout
        print_timeout(node, indent)
        print_ast(node[:contract], indent + 2)
      else
        raise "Unknown AST node type: #{node[:type]}"
      end
    end

    def print_schema(node, indent)
      puts "#{' ' * indent}Schema:"
      puts "#{' ' * (indent + 2)}Name: #{node[:name]}"
      puts "#{' ' * (indent + 2)}Properties:"
      node[:properties].each do |key, value|
        puts "#{' ' * (indent + 4)}#{key}: #{value}"
      end
    end

    def print_contract(node, indent)
      # puts_indent indent + 2, 'Contract:'.contract_text
      # puts_indent indent + 3, "Command: #{node[:command]}".command_text
      # puts_indent indent + 3, "Input: #{node[:input][:name]}".input_text
      # puts_indent indent + 3, "Output: #{node[:output][:name]}".output_text

      # [
      #   'Contract'.contract_text,
      #   '('.symbols_text,
      #   input.name.to_s.input_text,
      #   ' -> '.symbols_text,
      #   command.to_s.command_text,
      #   ' -> '.symbols_text,
      #   output.name.to_s.output_text,
      #   ')'.symbols_text
      # ].join

      puts_indent indent + 2,
                  Contract.format(node[:input][:name], node[:command],
                                  node[:output][:name])
    end

    def box_text(text)
      lines = text.lines
      max_sixe = lines.map(&:size).max
      box = '─' * (max_sixe + 2)
      [
        box,
        " #{text} ",
        # lines.map do |line|
        #   "│#{' ' * (line.size / 2)}#{line.chomp}#{' ' * (line.size / 2)}│"
        # end,
        box
      ].join("\n")
    end

    def print_schema_result_ast(node)
      return if node[:valid]

      puts box_text([
        indent_text(0, "⚠️ Type mismatch\n".upcase),
        indent_text(1, "- #{node[:errors].join(', ')}")
      ].join("\n")).symbols_text
    end

    def print_map(node, indent)
      # puts_indent indent, 'Map:'.compositon_text
      # puts_indent indent + 2, "Valid: #{node[:valid].valid?}".symbols_text
      # puts_indent indent + 2, "Input: #{node[:input][:name]}".input_text
      # puts_indent indent + 2, "Output: #{node[:output][:name]}".output_text
      # print_ast(node[:prev_contract], indent + 2)
      # print_ast(node[:next_contract], indent + 2)

      puts_indent indent, Map.format(node[:input][:name], node[:output][:name])
      print_schema_result_ast(node[:result])

      # puts_indent indent + 2, "Valid: #{node[:valid]}".symbols_text
      print_ast(node[:prev_contract], indent + 2)
      print_ast(node[:next_contract], indent + 2)
    end

    def print_tee(node, indent) # rubocop:disable Metrics/AbcSize
      puts "#{' ' * indent}Tee:"
      puts "#{' ' * (indent + 2)}Input: #{node[:input][:name]}"
      puts "#{' ' * (indent + 2)}Output: #{node[:output][:name]}"
      print_ast(node[:prev_contract], indent + 2)
      print_ast(node[:next_contract], indent + 2)
    end

    def print_or_else(node, indent)
      puts "#{' ' * indent}OrElse:"
      print_ast(node[:prev_contract], indent + 2)
      print_ast(node[:next_contract], indent + 2)
    end

    def print_retry(node, indent)
      puts "#{' ' * indent}Retry:"
      print_ast(node[:contract], indent + 2)
    end

    def print_timeout(node, indent)
      puts "#{' ' * indent}Timeout:"
      print_ast(node[:contract], indent + 2)
    end
  end
end
