# frozen_string_literal: true

require 'yaml'
module Covenant
  module Contracts
    module Monad
      def map(next_contract) = chain(Map, proc_or_class(next_contract))

      def tee(next_contract) = chain(Tee, proc_or_class(next_contract))

      def transform(input, output, &) = Transformer.new(self, input, output, &)

      def or_else(next_contract) = chain(OrElse, next_contract)

      def retry(max_attempts) = chain(Retry, max_attempts)

      def timeout(seconds) = chain(Timeout, seconds)

      def match(success:, failure:) = chain(Match, success, failure)

      def ast = Covenant::Ast::Ast.new(self)

      def to_ast = ast.to_ast

      def to_yaml = to_ast.to_yaml

      # def to_json = ast.to_json

      def to_s = ast.to_s

      def inspect = Covenant::Ast::AstShortPrinter.new(to_ast).print
      # puts Covenant::Ast::AstShortPrinter.new(to_ast).print

      # def print_ast = puts Covenant::Ast::AstShortPrinter.new(to_ast).print

      def chequer = Covenant::Ast::AstChecker.new(to_ast)

      def check! = chequer.check!

      alias and_then map

      def check_if_enable
        return self unless Covenant.check_contracts?

        check!

        self
      end

      def print_ast = puts Covenant::Ast::AstShortPrinter.new(to_ast).print

      private

      def chain(clazz, *rest) = clazz.new(self, *rest).check_if_enable

      def proc_or_class(contract) = contract.is_a?(Proc) ? contract.call(self) : contract
    end
  end
end
