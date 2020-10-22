# frozen_string_literal: true

module Mutations
  module Admin
    module Analytics
      module DevopsAdoption
        module Segments
          class Create < BaseMutation
            include Mixins::RequireAdminPermission
            include Mixins::BuildParams

            graphql_name 'CreateDevopsAdoptionSegment'

            argument :name, GraphQL::STRING_TYPE,
              required: true,
              description: 'Name of the segment'

            argument :group_ids, [::Types::GlobalIDType[::Group]],
              required: false,
              description: 'The array of group IDs to set for the segment'

            field :segment,
                  Types::Admin::Analytics::DevopsAdoption::SegmentType,
                  null: true,
                  description: 'Information about the status of the deletion request'

            def resolve(name:, group_ids: [], **)
              params = build_params(name: name, group_ids: group_ids)
              segment = ::Analytics::DevopsAdoption::Segment.create(params)

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
