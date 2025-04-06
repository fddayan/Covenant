# frozen_string_literal: true

module Covenant
  class AstShortPrinter < AstVisitor
    using ColorAliasRefinement

    def print_schema(node, indent)
      puts "#{' ' * indent}Schema:"
      puts "#{' ' * (indent + 2)}Name: #{node[:name]}"
      puts "#{' ' * (indent + 2)}Properties:"
      node[:properties].each do |key, value|
        puts "#{' ' * (indent + 4)}#{key}: #{value}"
      end
    end

    def print_contract(node, indent)
      # puts_indent indent + 2,
      #             Contract.format(
      #               node[:input][:name],
      #               node[:command],
      #               node[:output][:name]
      #             )

      puts_indent indent + 2, [
        node[:command].to_s.command_text,
        '('.symbols_text,
        # ' -> '.symbols_text,
        node[:input][:name].to_s.input_text,
        ' -> '.symbols_text,
        node[:output][:name].to_s.output_text,
        ')'.symbols_text
      ]
    end

    # def print_map_contract_separator(indent)
    #   Kernel.print '>>'
    # end

    def print_schema_result_ast(node)
      return if node[:valid]

      puts box_text([
        indent_text(0, "⚠️ Type mismatch\n".upcase),
        indent_text(1, "- #{node[:errors].join(', ')}")
      ].join("\n")).symbols_text
    end

    def print_map(node, indent)
      print_schema_result_ast(node[:result])
      # puts_indent indent, Map.format(node[:input][:name], node[:output][:name])
    end

    def print_tee(node, indent)
      puts "#{' ' * indent}Tee:"
      puts "#{' ' * (indent + 2)}Input: #{node[:input][:name]}"
      puts "#{' ' * (indent + 2)}Output: #{node[:output][:name]}"
    end

    def print_or_else(node, indent)
      puts "#{' ' * indent}OrElse:"
    end

    def print_retry(node, indent)
      puts "#{' ' * indent}Retry:"
    end
  end
end
