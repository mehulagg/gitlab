# frozen_string_literal: true

module Mutations
  module ReleaseAssetLinks
    class Create < BaseMutation
      graphql_name 'ReleaseAssetLinkCreate'

      authorize :create_release

      include Types::ReleaseAssetLinkSharedInputArguments

      argument :project_path, GraphQL::ID_TYPE,
               required: true,
               description: 'Full path of the project the asset link is associated with.'

      argument :tag_name, GraphQL::STRING_TYPE,
               required: true, as: :tag,
               description: "Name of the associated release's tag."

      field :link,
            Types::ReleaseAssetLinkType,
            null: true,
            description: 'The asset link after mutation.'

      def resolve(project_path:, tag:, **link_attrs)
        project = authorized_find!(project_path)
        release = project.releases.find_by_tag(tag)

        if release.nil?
          message = _('Release with tag "%{tag}" was not found') % { tag: tag }
          return { link: nil, errors: [message] }
        end

        new_link = release.links.create(link_attrs)

        unless new_link.persisted?
          return { link: nil, errors: new_link.errors.full_messages }
        end

        { link: new_link, errors: [] }
      end
    end
  end
end
