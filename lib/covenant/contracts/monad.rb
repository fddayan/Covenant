# frozen_string_literal: true

require 'yaml'
module Covenant
  module Contracts
    module Monad
      module ClassMethodsMonadicCompositions
        def match(success:, failure:) = chain(Compositions::Match, success, failure)
      end

      module InstanceMethodsMonadicCompositions
        def map(next_contract) = chain(Compositions::Map, proc_or_class(next_contract))

        def tee(next_contract) = chain(Compositions::Tee, proc_or_class(next_contract))

        def transform(input, output, &) = Compositions::Transformer.new(self, input, output, &)

        def or_else(next_contract) = chain(Compositions::OrElse, proc_or_class(next_contract))

        def retry(max_attempts) = chain(Compositions::Retry, max_attempts)

        def timeout(seconds) = chain(Compositions::Timeout, seconds)

        def match(success:, failure:) = chain(Compositions::Match, success, failure)

        alias and_then map

        private

        def chain(clazz, *rest) = clazz.new(self, *rest).check_if_enable

        def proc_or_class(contract) = contract.is_a?(Proc) ? contract.call(self) : contract
      end

      module AST
        def ast = Covenant::Ast::Ast.new(self)

        def to_ast = ast.to_ast

        def to_yaml = to_ast.to_yaml

        def to_s = ast.to_s

        def inspect = Covenant::Ast::AstShortPrinter.new(to_ast).print

        def chequer = Covenant::Ast::AstChecker.new(to_ast)

        def check! = chequer.check!

        def print_ast = puts Covenant::Ast::AstShortPrinter.new(to_ast).print

        # def to_json = ast.to_json

        # puts Covenant::Ast::AstShortPrinter.new(to_ast).print

        # def print_ast = puts Covenant::Ast::AstShortPrinter.new(to_ast).print
      end

      def check_if_enable
        return self unless Covenant.check_contracts?

        check!

        self
      end

      include InstanceMethodsMonadicCompositions
      include AST
      extend ClassMethodsMonadicCompositions
    end
  end
end
