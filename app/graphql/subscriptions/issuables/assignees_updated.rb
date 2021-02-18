# frozen_string_literal: true

module Subscriptions
  module Issuables
    class AssigneesUpdated < BaseSubscription
      payload_type [Types::UserType]

      argument :issuable_id, Types::GlobalIDType[Issuable],
              required: true,
              description: 'ID of the issuable.'

      def authorized?(issuable_id:)
        raise Gitlab::Graphql::Errors::ArgumentError, 'Invalid IssuableID' if issuable_id.is_a?(String) || issuable_id.model_class != Issue

        issuable = Gitlab::Graphql::Lazy.force(GitlabSchema.find_by_gid(issuable_id))
        issuable && Ability.allowed?(current_user, :"read_#{issuable.to_ability_name}", issuable)
      end
    end
  end
end
