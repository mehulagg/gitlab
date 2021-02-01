# frozen_string_literal: true

module Types
  class SubscriptionType < ::Types::BaseObject
    graphql_name 'Subscription'

    field :issue_updated, subscription: Subscriptions::IssueUpdated,
          description: 'Triggered when an issue is updated'
    field :merge_request_updated, subscription: Subscriptions::MergeRequestUpdated,
          description: 'Triggered when a merge request is updated'
  end
end
