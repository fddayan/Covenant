# frozen_string_literal: true

module Covenant
  module Ast
    class AstShortPrinter < AstVisitor
      using ColorAliasRefinement

      def print_contract(node, indent) = add_line(format_contract(node), indent)

      def format_contract(node)
        format(
          '%<command>s(:%<input>s -> :%<output>s)',
          command: node[:command].to_s.colorize(:cyan),
          input: node.dig(:input, :tag).to_s.colorize(:magenta),
          output: node.dig(:output, :tag).to_s.colorize(:light_blue)
        )
      end

      def print_map(node, indent)
        print_composition node, indent
        print_result(node, indent)
      end

      def print_result(node, indent)
        return if node[:result].nil?
        return if node.dig(:result, :success) == true

        add_line '⚠️ Error'.colorize(:red), indent
        add_line hash_to_sentence(node[:result][:errors]).colorize(:red), indent
      end

      def print_tee(node, indent)
        print_composition node, indent
        print_result(node, indent)
      end

      def print_match(node, indent)
        print_composition node, indent
        add_line 'success'.colorize(:yellow), indent + 2
        print_ast(node[:success], indent + 4)
        add_line 'failure'.colorize(:yellow), indent + 2
        print_ast(node[:failure], indent + 4)
      end

      def print_or_else(node, indent) = print_composition node, indent

      def print_retry(node, indent) = print_composition node, indent

      private

      def hash_to_sentence(hash) = hash.values.join(', ')

      def print_composition(node, indent) = add_line(format_composition(node), indent)

      def format_composition(node)
        format(
          '%<type>s(%<input>s -> %<output>s)',
          type: node[:type].to_s.colorize(:yellow),
          input: node.dig(:input, :tag).to_s.colorize(:magenta),
          output: node.dig(:output, :tag).to_s.colorize(:blue)
        )
      end
    end
  end
end
