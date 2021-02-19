# frozen_string_literal: true

module Gitlab
  module Ci
    module Pipeline
      module Expression
        class Statement
          StatementError = Class.new(Expression::ExpressionError)

          def initialize(statement, variables = nil)
            raise ArgumentError, "A Gitlab::Ci::Variables::Collection object was expected" unless
              variables.nil? || variables.is_a?(Gitlab::Ci::Variables::Collection)

            @lexer = Expression::Lexer.new(statement)
            @variables = variables&.to_hash
          end

          def parse_tree
            raise StatementError if @lexer.lexemes.empty?

            Expression::Parser.new(@lexer.tokens).tree
          end

          def evaluate
            parse_tree.evaluate(@variables.to_h)
          end

          def truthful?
            evaluate.present?
          rescue Expression::ExpressionError
            false
          end

          def valid?
            evaluate
            parse_tree.is_a?(Lexeme::Base)
          rescue Expression::ExpressionError
            false
          end
        end
      end
    end
  end
end
