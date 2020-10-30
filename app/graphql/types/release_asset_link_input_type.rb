# frozen_string_literal: true

module Types
  # rubocop: disable Graphql/AuthorizeTypes
  class ReleaseAssetLinkInputType < BaseInputObject
    graphql_name 'ReleaseAssetLinkInput'
    description 'Fields that are available when modifying a release asset link'

    argument :name, GraphQL::STRING_TYPE,
             required: true,
             description: 'Name of the link'

    argument :url, GraphQL::STRING_TYPE,
             required: true,
             description: 'URL of the link'

    argument :filepath, GraphQL::STRING_TYPE,
             required: false,
             description: 'Path for a direct asset link'

    argument :link_type, Types::ReleaseAssetLinkTypeEnum,
             required: false, default_value: 'other',
             description: 'The type of the link'
  end
end
