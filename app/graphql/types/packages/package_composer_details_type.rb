# frozen_string_literal: true

module Types
  module Packages
    class PackageComposerDetailsType < Types::Packages::PackageType
      graphql_name 'PackageComposerDetails'

      description 'Details of a composer package'

      authorize :read_package

      field :target_sha, GraphQL::STRING_TYPE, null: false, description: 'Target SHA of the package.'
      field :composer_json, Types::Packages::PackageComposerJsonType, null: false, description: 'Data of the composer.json file.'

      def target_sha
        object.composer_metadatum.target_sha
      end

      def composer_json
        object.composer_metadatum.composer_json
      end
    end
  end
end
