# frozen_string_literal: true

module Types
  class UserMergeRequestInteractionType < BaseObject
    graphql_name 'UserMergeRequestInteraction'

    authorize :read_merge_request

    field :can_merge, ::GraphQL::BOOLEAN_TYPE, null: false,
      extras: [:parent],
      calls_gitaly: true,
      resolver_method: :can_merge?,
      description: 'Whether this user can merge this merge request.'

    field :can_update_merge_request, ::GraphQL::BOOLEAN_TYPE, null: false,
      extras: [:parent],
      resolver_method: :can_update_merge_request?,
      description: 'Whether this user can update this merge request.'

    field :reviewed, ::GraphQL::BOOLEAN_TYPE, null: false,
      extras: [:parent],
      resolver_method: :reviewed?,
      description: 'Whether this user has reviewed this merge request.'

    field :approved, ::GraphQL::BOOLEAN_TYPE, null: false,
      extras: [:parent],
      resolver_method: :approved?,
      description: 'Whether this user has approved this merge request.'

    def can_merge?(parent:)
      merge_request.can_be_merged_by?(user(parent))
    end

    def can_update_merge_request?(parent:)
      user(parent).can?(:update_merge_request, merge_request)
    end

    def reviewed?(parent:)
      reviewer = merge_request.find_reviewer(user(parent))

      reviewer.present? && reviewer.reviewed?
    end

    def approved?(parent:)
      user_id = user(parent).id
      merge_request.approvals.any? { |app| app.user_id == user_id }
    end

    def merge_request
      object
    end

    def user(parent)
      parent.object.object
    end
  end
end
