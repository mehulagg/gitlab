# frozen_string_literal: true

module Resolvers
  class GroupsResolver < BaseResolver
    include LooksAhead
    type Types::GroupType, null: true

    argument :include_parent_descendants, GraphQL::BOOLEAN_TYPE,
             required: false,
             description: 'List of descendant groups of the parent group.',
             default_value: true

    alias_method :parent, :object

    def resolve_with_lookahead(**args)
      return [] unless parent.present?

      find_groups(transform_args(args))
    end

    private

    def find_groups(args)
      apply_lookahead(GroupsFinder.new(context[:current_user], args).execute)
    end

    def transform_args(args)
      transformed = args.dup
      transformed[:parent] = parent
      transformed[:include_parent_descendants] = args[:include_parent_descendants]

      transformed
    end
  end
end
