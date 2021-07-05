# frozen_string_literal: true

module Types
  # rubocop: disable Graphql/AuthorizeTypes
  class NetworkPolicyType < BaseObject
    graphql_name 'NetworkPolicy'
    description 'Represents the network policy'

    field :name,
          GraphQL::STRING_TYPE,
          null: false,
          description: 'Name of the policy.'

    field :kind,
          GraphQL::STRING_TYPE,
          null: false,
          description: 'Kind of the policy.'

    field :namespace,
          GraphQL::STRING_TYPE,
          null: false,
          description: 'Namespace of the policy.'

    field :enabled,
          GraphQL::BOOLEAN_TYPE,
          null: false,
          description: 'Indicates whether this policy is enabled.'

    field :from_auto_devops,
          GraphQL::BOOLEAN_TYPE,
          null: false,
          description: 'Indicates whether this policy is created from AutoDevops.'

    field :yaml,
          GraphQL::STRING_TYPE,
          null: false,
          description: 'YAML definition of the policy.'

    field :updated_at,
          Types::TimeType,
          null: false,
          description: 'Timestamp of when the policy YAML was last updated.'
  end
end
