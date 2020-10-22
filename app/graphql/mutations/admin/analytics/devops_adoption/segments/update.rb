# frozen_string_literal: true

module Mutations
  module Admin
    module Analytics
      module DevopsAdoption
        module Segments
          class Update < BaseMutation
            include Mixins::RequireAdminPermission
            include Mixins::BuildParams

            graphql_name 'UpdateDevopsAdoptionSegment'

            argument :id, ::Types::GlobalIDType[::Analytics::DevopsAdoption::Segment],
              required: true,
              description: "ID of the segment"

            argument :name, GraphQL::STRING_TYPE,
              required: false,
              description: 'Name of the segment'

            argument :group_ids, [::Types::GlobalIDType[::Group]],
              required: false,
              description: 'The array of group IDs to set for the segment'

            field :segment,
              Types::Admin::Analytics::DevopsAdoption::SegmentType,
              null: true,
              description: 'Information about the status of the deletion request'

            def resolve(id:, name:, group_ids: nil, **)
              segment = id.find
              params = build_params({ name: name, group_ids: group_ids }, segment.segment_selections)

              segment.update(params)

              {
                segment: segment.persisted? ? segment : nil,
                errors: errors_on_object(segment)
              }
            end
          end
        end
      end
    end
  end
end
