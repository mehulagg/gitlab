# frozen_string_literal: true

# This cop checks for use of older GraphQL  types in GraphQL fields
# and arguments.
# GraphQL::ID_TYPE, GraphQL::INT_TYPE, GraphQL::STRING_TYPE, GraphQL::BOOLEAN_TYPE
#
# @example
#
#   # bad
#   class AwfulClass
#     field :some_field, GraphQL::STRING_TYPE
#   end
#
#   # good
#   class GreatClass
#     field :some_field, GraphQL::Types::String
#   end

module RuboCop
  module Cop
    module Graphql
      class OldTypes < RuboCop::Cop::Cop
        MSG_ID      = 'Avoid using GraphQL::ID_TYPE. Use GraphQL::Types::ID instead'
        MSG_INT     = 'Avoid using GraphQL::INT_TYPE. Use GraphQL::Types::Int instead'
        MSG_STRING  = 'Avoid using GraphQL::STRING_TYPE. Use GraphQL::Types::String instead'
        MSG_BOOLEAN = 'Avoid using GraphQL::BOOLEAN_TYPE. Use GraphQL::Types::Boolean instead'

        def_node_matcher :has_id_type?, <<~PATTERN
          (send nil? {:field :argument}
            (sym _)
            (const (const nil? :GraphQL) :ID_TYPE)
            (...)?)
        PATTERN

        def_node_matcher :has_int_type?, <<~PATTERN
          (send nil? {:field :argument}
            (sym _)
            (const (const nil? :GraphQL) :INT_TYPE)
            (...)?)
        PATTERN

        def_node_matcher :has_string_type?, <<~PATTERN
          (send nil? {:field :argument}
            (sym _)
            (const (const nil? :GraphQL) :STRING_TYPE)
            (...)?)
        PATTERN

        def_node_matcher :has_boolean_type?, <<~PATTERN
          (send nil? {:field :argument}
            (sym _)
            (const (const nil? :GraphQL) :BOOLEAN_TYPE)
            (...)?)
        PATTERN

        def on_send(node)
          add_offense(node, location: :expression, message: MSG_ID) if has_id_type?(node)
          add_offense(node, location: :expression, message: MSG_INT) if has_int_type?(node)
          add_offense(node, location: :expression, message: MSG_STRING) if has_string_type?(node)
          add_offense(node, location: :expression, message: MSG_BOOLEAN) if has_boolean_type?(node)
        end
      end
    end
  end
end
