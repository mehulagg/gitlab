# frozen_string_literal: true

module Resolvers
  class EpicAncestorsResolver < EpicsResolver
    type Types::EpicType, null: true

    argument :include_ancestor_groups, GraphQL::BOOLEAN_TYPE,
             required: false,
             description: 'Include epics from ancestor groups.',
             default_value: true

    private

    def set_relative_param(args)
      args[:child_id] = parent.id if parent

      args
    end
  end
end
