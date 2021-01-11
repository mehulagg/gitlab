# frozen_string_literal: true

module Types
  module Packages
    module Composer
      class DetailsType < Types::Packages::PackageType
        graphql_name 'PackageComposerDetails'
        description 'Details of a composer package'

        authorize :read_package

        field :composer_metadatum, Types::Packages::Composer::MetadatumType, null: false, description: 'The composer metadatum'
      end
    end
  end
end
