# frozen_string_literal: true

module Types
  # rubocop:disable Graphql/AuthorizeTypes
  class UserCalloutType < BaseObject
    graphql_name 'UserCallout'

    field :feature_name, UserCalloutFeatureNameEnum, null: false,
      description: 'Name of the feature that the callout is for.'
    field :dismissed_at, Types::TimeType, null: true,
      description: 'Date when the callout was dismissed.'
  end
  # rubocop:enable Graphql/AuthorizeTypes
end
