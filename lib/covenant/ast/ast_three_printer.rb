# frozen_string_literal: true

module Covenant
  class AstThreePrinter < AstVisitor
    using ColorAliasRefinement

    def indent_text(indent, text)
      "#{' ' * indent}#{text}"
    end

    def puts_indent(indent, text_or_arr)
      text = text_or_arr.is_a?(Array) ? text_or_arr.join : text_or_arr
      puts "#{' ' * indent}#{text}"
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

      puts_indent indent + 2,
                  Contracts::Contract.format(
                    node[:input][:name],
                    node[:command],
                    node[:output][:name]
                  )
    end

    def box_text(text)
      lines = text.lines
      max_sixe = lines.map(&:size).max
      box = '─' * (max_sixe + 2)
      [box, " #{text} "].join("\n")
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

      puts_indent indent,
                  Contracts::Map.format(node[:input][:name],
                                        node[:output][:name])
      # print_ast(node[:prev_contract], indent + 2)
      # print_ast(node[:next_contract], indent + 2)
    end

    def print_tee(node, indent)
      puts "#{' ' * indent}Tee:"
      puts "#{' ' * (indent + 2)}Input: #{node[:input][:name]}"
      puts "#{' ' * (indent + 2)}Output: #{node[:output][:name]}"
      # print_ast(node[:prev_contract], indent + 2)
      # print_ast(node[:next_contract], indent + 2)
    end

    def print_or_else(_node, indent)
      puts "#{' ' * indent}OrElse:"
      # print_ast(node[:prev_contract], indent + 2)
      # print_ast(node[:next_contract], indent + 2)
    end

    def print_retry(_node, indent)
      puts "#{' ' * indent}Retry:"
      # print_ast(node[:contract], indent + 2)
    end
  end
end
