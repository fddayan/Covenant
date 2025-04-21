# frozen_string_literal: true

module Covenant
  module Ast
    class AstError
      # attr_reader :errors

      def initialize(errors) = @errors = errors

      def empty?
        return true if @errors.nil? || @errors.empty?

        @errors.all? do |error|
          error.is_a?(Hash) && error.values.all? { |v| v.nil? || v.empty? }
        end
      end

      def to_s = errors.join("\n")

      def errors = errors_to_sentences(@errors)

      private

      def errors_to_sentences(errors, path = '')
        errors.flat_map { |error| error_to_sentence(error, path) }.compact
      end

      def error_to_sentence(error, path)
        if error.is_a?(Hash)
          error.filter_map do |k, v|
            next nil if v.nil? || v.empty?

            "#{path}#{k}: #{v.join(', ')}"
          end
        else
          key, value = error
          return nil if value.nil? || value.empty?

          errors_to_sentences(value, "#{path}#{key}.")
        end
      end
    end

    class AstResult
      attr_reader :success, :errors

      def self.success(node) = new node: node, errors: []

      def self.failure(node, errors) = new(node:, errors: errors)

      def initialize(node:, errors:)
        @node = node
        @errors = AstError.new(errors)
      end

      def success? = @errors.nil? || @errors.empty?

      def failure? = !success?

      def unwrap = @errors

      def to_s
        if success?
          "#{self.class}(Success)"
        else
          # "#{self.class}(Failure: #{@errors.join(',')})"
          # "#{self.class}(Failure) #{format_error}"
          format_error
        end
      end

      private

      # def errors_to_sentences(errors, path = '')
      #   errors.flat_map do |error|
      #     if error.is_a?(Hash)
      #       error.filter_map do |k, v|
      #         next nil if v.nil? || v.empty?

      #         "#{path}#{k}: #{v.join(', ')}"
      #       end
      #     else
      #       key, value = error
      #       next nil if value.nil? || value.empty?

      #       errors_to_sentences(value, "#{path}#{key}.")
      #     end
      #   end.compact
      # end

      # def format_tag(tag) = ":#{tag}"

      def format_contract(contract)
        format(
          '(:%<input>s -> %<command>s -> :%<output>s)',
          input: contract.dig(:input, :tag),
          command: contract[:command],
          output: contract.dig(:output, :tag)
        )
      end

      def format_error
        # ap @node

        format(
          '%<type>s[ %<prev_contract>s -> %<next_contract>s ] > %<errors>s',
          type: @node[:type],
          prev_contract: format_contract(@node[:prev_contract]),
          next_contract: format_contract(@node[:next_contract]),
          errors: @errors.errors.join(', ')
        )

        # [
        #   @node[:type],
        #   '(',
        #   format_contract(@node[:prev_contract]),
        #   ' -> ',
        #   format_contract(@node[:next_contract]),
        #   ')'
        # ].join

        # [
        #   [
        #     @node[:type],
        #     '(',
        #     format_contract(@node[:prev_contract]),
        #     ' -> ',
        #     format_contract(@node[:next_contract]),
        #     ')'
        #   ].join,
        #   "> #{@errors.errors.join(', ')}"
        # ].join("\n")
      end
    end

    class AstChecker
      def initialize(ast)
        @ast = ast
        @errors = []
      end

      def check
        check_ast_node(@ast)

        @errors
      end

      def ast_result(node, result)
        return AstResult.success(node) if result.nil? || result[:success]

        AstResult.failure(node, result[:errors])
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
