# frozen_string_literal: true

module Types
  module Geo
    # rubocop:disable Graphql/AuthorizeTypes because it is included
    class UploadRegistryType < BaseObject
      include ::Types::Geo::RegistryType

      graphql_name 'UploadRegistry'
      description 'Represents the Geo replication and verification state of a upload'

      field :upload_id, GraphQL::ID_TYPE, null: false, description: 'ID of the Upload'
    end
  end
end
