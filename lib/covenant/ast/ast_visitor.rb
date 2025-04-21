# frozen_string_literal: true

module Covenant
  module Ast
    class AstVisitor
      using ColorAliasRefinement

      def initialize(ast)
        @ast = ast
        @lines = []
      end

      def print
        print_ast(@ast)

        @lines.join("\n")
      end

      def puts_indent(indent, text_or_arr)
        text = text_or_arr.is_a?(Array) ? text_or_arr.join : text_or_arr
        @lines << "#{' ' * indent}#{text}"
      end

      def indent_text(indent, text) = "#{' ' * indent}#{text}"

      def print_ast(node, indent = 0) # rubocop:disable Metrics/AbcSize,Metrics/MethodLength,Metrics/CyclomaticComplexity
        case node[:type]
        when :contract
          print_contract(node, indent)
        when :map
          print_map(node, indent)
          print_ast(node[:prev_contract], indent + 2)
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
        when :match
          puts node
          print_ast(node[:success], indent + 2)
          print_ast(node[:failure], indent + 2)
        else
          raise "Unknown AST node type: #{node[:type]}"
        end
      end

      # def print_schema(node, indent)
      #   @lines << "#{' ' * indent}Schema:"
      #   @lines << "#{' ' * (indent + 2)}Name: #{node[:name]}"
      #   @lines << "#{' ' * (indent + 2)}Properties:"
      #   node[:properties].each do |key, value|
      #     @lines << "#{' ' * (indent + 4)}#{key}: #{value}"
      #   end
      # end
      #
      # def print_contract(node, indent)
      #   puts_indent indent + 2,
      #               Contract.format(node[:input][:name], node[:command],
      #                               node[:output][:name])
      # end
      #
      # def box_text(text)
      #   lines = text.lines
      #   max_sixe = lines.map(&:size).max
      #   box = '─' * (max_sixe + 2)
      #   [
      #     box,
      #     " #{text} ",
      #     box
      #   ].join("\n")
      # end
      #
      # def print_schema_result_ast(node)
      #   return if node[:valid]
      #
      #   @lines << box_text([
      #     indent_text(0, "⚠️ Type mismatch\n".upcase),
      #     indent_text(1, "- #{node[:errors].join(', ')}")
      #   ].join("\n")).symbols_text
      # end
      #
      # def print_map(node, indent)
      #   puts_indent indent,
      #               Map.format(node[:input][:name], node[:output][:name])
      #   print_schema_result_ast(node[:result])
      #
      #   # puts_indent indent + 2, "Valid: #{node[:valid]}".symbols_text
      #   print_ast(node[:prev_contract], indent + 2)
      #   print_ast(node[:next_contract], indent + 2)
      # end
      #
      # def print_tee(node, indent)
      #   @lines << "#{' ' * indent}Tee:"
      #   @lines << "#{' ' * (indent + 2)}Input: #{node[:input][:name]}"
      #   @lines << "#{' ' * (indent + 2)}Output: #{node[:output][:name]}"
      #   print_ast(node[:prev_contract], indent + 2)
      #   print_ast(node[:next_contract], indent + 2)
      # end
      #
      # def print_or_else(node, indent)
      #   @lines << "#{' ' * indent}OrElse:"
      #   print_ast(node[:prev_contract], indent + 2)
      #   print_ast(node[:next_contract], indent + 2)
      # end
      #
      # def print_retry(node, indent)
      #   @lines << "#{' ' * indent}Retry:"
      #   print_ast(node[:contract], indent + 2)
      # end
      #
      # def print_timeout(node, indent)
      #   @lines << "#{' ' * indent}Timeout:"
      #   print_ast(node[:contract], indent + 2)
      # end
    end
  end
end
