# frozen_string_literal: true

module Covenant
  module Ast
    class AstVisitor
      using ColorAliasRefinement

      INCR = 1

      def initialize(ast)
        @ast = ast
        @lines = []
      end

      def print
        print_ast(@ast)

        @lines.join("\n")
      end

      def add_line_format(text, indent, **opts) = add_line(format(text, **opts), indent)

      def add_line(text, indent) = @lines << indent_text(indent, text)

      def indent_text(indent, text) = "#{' ' * indent}#{text}"

      def print_ast(node, indent = 0) # rubocop:disable Metrics/AbcSize,Metrics/MethodLength,Metrics/CyclomaticComplexity
        case node[:type]
        when :contract
          print_contract(node, indent)
        when :map
          print_ast(node[:prev_contract], indent)
          print_map(node, indent)
          print_ast(node[:next_contract], indent + INCR)
        when :tee
          print_ast(node[:prev_contract], indent)
          print_tee(node, indent)
          print_ast(node[:next_contract], indent + INCR)
        when :or_else
          print_ast(node[:prev_contract], indent)
          print_or_else(node, indent)
          print_ast(node[:next_contract], indent + INCR)
        when :retry
          print_retry(node, indent)
          print_ast(node[:contract], indent + INCR)
        when :timeout
          print_timeout(node, indent)
          print_ast(node[:contract], indent + INCR)
        when :match
          print_match(node, indent + INCR)
        else
          raise "Unknown AST node type: #{node[:type]}"
        end
      end
    end
  end
end
