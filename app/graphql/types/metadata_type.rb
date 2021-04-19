# frozen_string_literal: true

module Types
  class MetadataType < ::Types::BaseObject
    graphql_name 'Metadata'

    authorize :read_instance_metadata

    field :version, GraphQL::STRING_TYPE, null: false,
          description: 'Version.'
    field :revision, GraphQL::STRING_TYPE, null: false,
          description: 'Revision.'
    field :kas_external_address, GraphQL::STRING_TYPE, description: 'The address used by KAS to communicate with Agents.'
    field :kas_enabled, GraphQL::BOOLEAN_TYPE,
          null: false, description: 'Indicates whether the Kubernetes Agent Server is enabled.'
  end
end
