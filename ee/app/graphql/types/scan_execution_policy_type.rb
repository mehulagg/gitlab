# frozen_string_literal: true

module Types
  # rubocop: disable Graphql/AuthorizeTypes
  class ScanExecutionPolicyType < BaseObject
    graphql_name 'ScanExecutionPolicy'
    description 'Represents the scan execution policy'

    field :name, GraphQL::STRING_TYPE, null: false, description: 'Name of the policy.'
    field :description, GraphQL::STRING_TYPE, null: false, description: 'Description of the policy.'
    field :enabled, GraphQL::BOOLEAN_TYPE, null: false, description: 'Indicates whether this policy is enabled.'
    field :yaml, GraphQL::STRING_TYPE, null: false, description: 'YAML definition of the policy.'
    field :updated_at, Types::TimeType, null: false, description: 'Timestamp of when the policy YAML was last updated.'
  end
end
