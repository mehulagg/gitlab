# frozen_string_literal: true

# This cop checks for missing GraphQL type annotations on resolvers
#
# @example
#
#   # bad
#   module Resolvers
#     class NoTypeResolver < BaseResolver
#       field :some_field, GraphQL::STRING_TYPE
#     end
#   end
#
#   # good
#   module Resolvers
#     class WithTypeResolver < BaseResolver
#       type MyType, null: true
#
#       field :some_field, GraphQL::STRING_TYPE
#     end
#   end

module RuboCop
  module Cop
    module Graphql
      class ResolverType < RuboCop::Cop::Cop
        EXCLUDED = ['BaseResolver'].freeze

        MSG = 'Missing type annotation: Please add `type` DSL method call. ' \
          'e.g: type UserType.connection_type, null: true'

        def_node_matcher :typed?, <<~PATTERN
          (... (begin <(send nil? :type ...) ...>))
        PATTERN

        def on_class(node)
          add_offense(node, location: :expression) if relevant?(node) && !typed?(node)
        end

        private

        def relevant?(node)
          class_name = node.loc.name.source

          class_name.end_with?('Resolver') && !EXCLUDED.include?(class_name)
        end
      end
    end
  end
end
