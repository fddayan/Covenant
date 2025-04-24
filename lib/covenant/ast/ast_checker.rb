# frozen_string_literal: true

module Covenant
  module Ast
    class AstChecker
      def initialize(ast)
        @ast = ast
        @errors = []
      end

      def check
        check_ast_node(@ast)

        @errors
      end

      def check!
        check
        raise Covenant::ContractViolation, @errors unless @errors.empty?
      end

      def ast_result(node, result)
        return AstCheckResult.success(node) if result.nil? || result[:success]

        AstCheckResult.failure(node, result[:errors])
      end

      def check_ast_node(node) # rubocop:disable Metrics/CyclomaticComplexity,Metrics/MethodLength
        @errors << ast_result(node, node[:result])

        case node[:type]
        when :map
          check_map(node)
        # when :struct_compare
        #   check_struct_compare(node)
        when :struct
          # check_struct(node)
        when :tee
          check_tee(node)
        when :or_else
          check_or_else(node)
        when :retry
          check_retry(node)
        when :timeout
          check_timeout(node)
        when :match
          check_match(node)
        when :contract
          # check_contract(node)
        else
          raise "Unknown AST node type: #{node.type}"
        end
      end

      def check_map(node)
        check_ast_node(node[:prev_contract])
        check_ast_node(node[:next_contract])
      end

      def check_tee(node)
        check_ast_node(node[:prev_contract])
        check_ast_node(node[:next_contract])
      end

      def check_or_else(node)
        check_ast_node(node[:prev_contract])
        check_ast_node(node[:next_contract])
      end

      def check_retry(node) = check_ast_node(node[:contract])

      def check_timeout(node) = check_ast_node(node[:contract])

      def check_match(node)
        check_ast_node(node[:success])
        check_ast_node(node[:failure])
      end
    end
  end
end
