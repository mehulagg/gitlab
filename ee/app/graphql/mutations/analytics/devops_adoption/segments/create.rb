# frozen_string_literal: true

module Mutations
  module Analytics
    module DevopsAdoption
      module Segments
        class Create < BaseMutation
          include Mixins::CommonMethods

          graphql_name 'CreateDevopsAdoptionSegment'

          description '**BETA** This endpoint is subject to change without notice.'

          argument :namespace_id, ::Types::GlobalIDType[::Namespace],
                   required: true,
                   description: 'Namespace ID to set for the segment.'

          argument :display_namespace_id, ::Types::GlobalIDType[::Namespace],
                   required: false,
                   description: 'Display namespace ID.'

          field :segment,
                Types::Admin::Analytics::DevopsAdoption::SegmentType,
                null: true,
                description: 'The segment after mutation.'

          def resolve(namespace_id:, display_namespace_id: nil, **)
            namespace = Gitlab::Graphql::Lazy.force(GitlabSchema.find_by_gid(namespace_id))
            display_namespace = Gitlab::Graphql::Lazy.force(GitlabSchema.find_by_gid(display_namespace_id))

            with_authorization_handler do
              service = ::Analytics::DevopsAdoption::Segments::CreateService
                .new(current_user: current_user, params: { namespace: namespace, display_namespace: display_namespace })

              response = service.execute

              resolve_segment(response)
            end
          end
        end
      end
    end
  end
end
