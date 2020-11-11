# frozen_string_literal: true

# This cop checks for missing GraphQL type annotations on resolvers
#
# @example
#
#   # bad
#   module Resolvers
#     class NoType < BaseResolver
#       field :some_field, GraphQL::STRING_TYPE
#     end
#   end
#
#   # good
#   module Resolvers
#     class WithType < BaseResolver
#       type MyType, null: true
#
#       field :some_field, GraphQL::STRING_TYPE
#     end
#   end

module RuboCop
  module Cop
    module Graphql
      class ResolverType < RuboCop::Cop::Cop
        MSG = 'Missing type annotation: Please add `type` DSL method call. ' \
          'e.g: type UserType.connection_type, null: true'

        def_node_matcher :type_dsl_call?, <<~PATTERN
          (send nil? :type ...)
        PATTERN

        def on_class(node)
          add_offense(node, location: :expression) if resolver?(node) && !typed?(node)
        end

        private

        def typed?(class_node)
          body = class_node.children[2]&.children
          return false unless body

          body.any? { |declaration| type_dsl_call?(declaration) }
        end

        def resolver?(node)
          class_name = class_constant(node)&.short_name&.to_s

          class_name.present? && class_name.end_with?('Resolver')
        end

        def class_constant(node)
          node.descendants.first
        end
      end
    end
  end
end
