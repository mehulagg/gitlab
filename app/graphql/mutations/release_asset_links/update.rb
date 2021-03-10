# frozen_string_literal: true

module Mutations
  module ReleaseAssetLinks
    class Update < Base
      graphql_name 'ReleaseAssetLinkUpdate'

      authorize :update_release

      include Types::ReleaseAssetLinkSharedInputArguments

      ReleaseAssetLinkID = ::Types::GlobalIDType[::Releases::Link]

      argument :id, ReleaseAssetLinkID, required: true,
               description: 'ID of the release asset link to update.'

      field :link,
            Types::ReleaseAssetLinkType,
            null: true,
            description: 'The asset link after mutation.'

      def resolve(project_path:, tag:, **link_attrs)

      end
    end
  end
end
