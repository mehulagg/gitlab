# frozen_string_literal: true

module Types
  module Geo
    # rubocop:disable Graphql/AuthorizeTypes because it is included
    class TerraformStateRegistryType < BaseObject
      include ::Types::Geo::RegistryType

      graphql_name 'TerraformStateRegistry'
      description 'Represents the Geo sync and verification state of a terraform state'

      field :terraform_state_id, GraphQL::ID_TYPE, null: false, description: 'ID of the TerraformState'
    end
  end
end
