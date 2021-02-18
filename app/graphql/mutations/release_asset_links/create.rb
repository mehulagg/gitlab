# frozen_string_literal: true

module Mutations
  module ReleaseAssetLinks
    class Create < Base
      graphql_name 'ReleaseAssetLinkCreate'

      authorize :create_release

      field :link,
            Types::ReleaseAssetLinkType,
            null: true,
            description: 'The asset link after mutation.'

      argument :name, GraphQL::STRING_TYPE,
               required: true,
               description: 'Name of the asset link.'

      argument :url, GraphQL::STRING_TYPE,
               required: true,
               description: 'URL of the asset link.'

      argument :direct_asset_path, GraphQL::STRING_TYPE,
               required: false, as: :filepath,
               description: 'Relative path for a direct asset link.'

      argument :link_type, Types::ReleaseAssetLinkTypeEnum,
               required: false, default_value: 'other',
               description: 'The type of the asset link.'

      def resolve(project_path:, tag:, **link_attrs)
        project = authorized_find!(project_path)
        release = project.releases.find_by_tag(tag)

        if release.nil?
          raise Gitlab::Graphql::Errors::ResourceNotAvailable, "release with tag #{tag} was not found in project #{project_path}"
        end

        new_link = release.links.create(link_attrs)

        unless new_link.persisted?
          raise Gitlab::Graphql::Errors::BaseError, new_link.errors.messages.to_s
        end

        { link: new_link, errors: [] }
      end
    end
  end
end
