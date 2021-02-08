# frozen_string_literal: true

module Resolvers
  class LabelsResolver < BaseResolver
    argument :search_term, GraphQL::STRING_TYPE,
             required: false,
             description: 'A search term to find labels with.'

    argument :include_ancestor_groups, GraphQL::BOOLEAN_TYPE,
             required: false,
             description: 'Include labels from ancestor groups.',
             default_value: true

    argument :include_descendant_groups, GraphQL::BOOLEAN_TYPE,
             required: false,
             description: 'Include labels from descendant groups.',
             default_value: true

    argument :only_group_labels, GraphQL::BOOLEAN_TYPE,
             required: false,
             description: 'Include only group level labels.',
             default_value: false

    type Types::LabelType.connection_type, null: true

    def resolve(**args)
      authorize!

      LabelsFinder.new(current_user, parent_param.merge(args)).execute
    end

    def parent
      object.respond_to?(:sync) ? object.sync : object
    end

    def parent_param
      if parent.is_a?(group)
        { group: parent }
      else
        { project: parent }
      end
    end

    def authorize!
      Ability.allowed?(context[:current_user], :read_label, parent) || raise_resource_not_available_error!
    end
  end
end
