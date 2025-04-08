# frozen_string_literal: true

module Covenant
  module Ast
    class AstShortPrinter < AstVisitor
      using ColorAliasRefinement

      def print_schema(node, indent)
        @lines << "#{' ' * indent}Schema:"
        @lines << "#{' ' * (indent + 2)}Name: #{node[:name]}"
        @lines << "#{' ' * (indent + 2)}Properties:"
        node[:properties].each do |key, value|
          @lines << "#{' ' * (indent + 4)}#{key}: #{value}"
        end
      end

      def print_contract(node, indent)
        contract = [
          node[:command].to_s.command_text,
          '('.symbols_text,
          # ' -> '.symbols_text,
          node[:input][:tag].to_s.input_text,
          ' -> '.symbols_text,
          node[:output][:tag].to_s.output_text,
          ')'.symbols_text
        ].join { "\n" }

        contract = contract.red unless node[:opts][:success]

        puts_indent indent + 2, contract
      end

      def print_struct_compare_ast(node)
        return if node[:success]

        @lines << indent_text(0, '⚠️ Type mismatch').symbols_text
        @lines << node[:errors].map { |s| "* #{s}" }.join("- \n").symbols_text
        # @lines << "\n"
      end

      def print_map(node, _indent)
        print_struct_compare_ast(node[:result])
      end

      def print_tee(node, indent)
        @lines << "#{' ' * indent}Tee:"
        @lines << "#{' ' * (indent + 2)}Input: #{node[:input][:tag]}"
        @lines << "#{' ' * (indent + 2)}Output: #{node[:output][:tag]}"
      end

      def print_or_else(_node, indent)
        @lines << "#{' ' * indent}OrElse:"
      end

      def print_retry(_node, indent)
        @lines << "#{' ' * indent}Retry:"
      end
    end
  end
end
