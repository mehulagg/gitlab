# frozen_string_literal: true

# This cop checks for missing GraphQL field descriptions.
#
# @example
#
#   # bad
#   class AwfulClass
#     field :some_field, GraphQL::STRING_TYPE
#   end
#
#   class TerribleClass
#     argument :some_argument, GraphQL::STRING_TYPE
#   end
#
#   class AppallingClass
#     field :some_argument,
#       GraphQL::STRING_TYPE,
#       description: "A description that ends in a period."
#   end
#
#   # good
#   class GreatClass
#     argument :some_field,
#       GraphQL::STRING_TYPE,
#       description: "Well described - a superb description"
#
#     field :some_field,
#       GraphQL::STRING_TYPE,
#       description: "A thorough and compelling description"
#   end

module RuboCop
  module Cop
    module Graphql
      class Descriptions < RuboCop::Cop::Cop
        MSG_NO_DESCRIPTION = 'Please add a `description` property.'
        MSG_REMOVE_PERIOD = '`description` strings must not end with a `.`'

        # ability_field and permission_field set a default description.
        def_node_matcher :fields, <<~PATTERN
          (send nil? :field $...)
        PATTERN

        def_node_matcher :arguments, <<~PATTERN
          (send nil? :argument $...)
        PATTERN

        def_node_matcher :description, <<~PATTERN
          (hash <(pair (sym :description) $_) ...>)
        PATTERN

        def on_send(node)
          matches = fields(node) || arguments(node)

          return if matches.nil?

          description = description(matches.last)

          return add_offense(node, location: :expression, message: MSG_NO_DESCRIPTION) unless description

          add_offense(node, location: :expression, message: MSG_REMOVE_PERIOD) if description_ends_with_period?(description)
        end

        private

        def description_ends_with_period?(description)
          # Test that the description node is a `:str` (as opposed to
          # a `#copy_field_description` call) before checking.
          description.type == :str && description.value.end_with?('.')
        end
      end
    end
  end
end
