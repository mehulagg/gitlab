# frozen_string_literal: true

module Mutations
  module ContainerRepositories
    class DestroyTags < Mutations::BaseMutation
      include ::Mutations::PackageEventable

      LIMIT = 20.freeze

      graphql_name 'DestroyContainerRepositoryTags'

      authorize :destroy_container_image

      argument :id,
               ::Types::GlobalIDType[::ContainerRepository],
               required: true,
               description: 'ID of the container repository.'

      argument :tag_names,
               [String],
               required: true,
               description: 'Container repository tag names'

      field :deleted_tag_names,
            [String],
            description: 'Deleted container repository tag names',
            null: false

      def resolve(id:, tag_names:)
        return too_many_tags_error_response if tag_names.size > LIMIT

        container_repository = authorized_find!(id: id)

        result = ::Projects::ContainerRepository::DeleteTagsService
          .new(container_repository.project, current_user, tags: tag_names)
          .execute(container_repository)

        track_event(:delete_tag_bulk, :tag)

        {
          errors: [result[:message]].compact,
          deleted_tag_names: result[:deleted]
        }
      end

      private

      def find_object(id:)
        # TODO: remove this line when the compatibility layer is removed
        # See: https://gitlab.com/gitlab-org/gitlab/-/issues/257883
        id = ::Types::GlobalIDType[::ContainerRepository].coerce_isolated_input(id)
        GitlabSchema.find_by_gid(id)
      end

      def too_many_tags_error_response
        {
          errors: ["Tag names size is bigger than #{LIMIT}"],
          deleted_tag_names: []
        }
      end
    end
  end
end
