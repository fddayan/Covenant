# frozen_string_literal: true

module Covenant
  module Ast
    class AstThreePrinter < AstVisitor
      using ColorAliasRefinement

      def indent_text(indent, text)
        "#{' ' * indent}#{text}"
      end

      def puts_indent(indent, text_or_arr)
        text = text_or_arr.is_a?(Array) ? text_or_arr.join : text_or_arr
        @lines << "#{' ' * indent}#{text}"
      end

      def print_schema(node, indent)
        @lines << "#{' ' * indent}Schema:"
        @lines << "#{' ' * (indent + 2)}Name: #{node[:name]}"
        @lines << "#{' ' * (indent + 2)}Properties:"
        node[:properties].each do |key, value|
          @lines << "#{' ' * (indent + 4)}#{key}: #{value}"
        end
      end

      def print_contract(node, indent)
        puts_indent indent + 2, format_contract(node)
      end

      def format_contract(node)
        Contracts::Contract.format(
          node[:input][:tag],
          node[:command],
          node[:output][:tag]
        )
      end

      def box_text(text)
        lines = text.lines
        max_sixe = lines.map(&:size).max
        box = '─' * (max_sixe + 2)
        [box, " #{text} "].join("\n")
      end

      def print_map(node, indent)
        puts_indent indent,
                    Contracts::Map.format(node[:input][:tag],
                                          node[:output][:tag])
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
