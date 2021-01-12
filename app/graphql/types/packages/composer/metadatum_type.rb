# frozen_string_literal: true

module Types
  module Packages
    module Composer
      class MetadatumType < BaseObject
        graphql_name 'PackageComposerMetadatumType'
        description 'Composer metadatum'

        authorize :read_package

        field :target_sha, GraphQL::STRING_TYPE, null: false, description: 'Target SHA of the package.'
        field :composer_json, Types::Packages::Composer::JsonType, null: false, description: 'Data of the composer JSON file.'
      end
    end
  end
end
