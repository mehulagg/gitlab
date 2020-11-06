# frozen_string_literal: true

module Mutations
  module Admin
    module Analytics
      module DevopsAdoption
        module Segments
          class Update < BaseMutation
            include Mixins::CommonMethods
            include Mixins::CommonArguments

            graphql_name 'UpdateDevopsAdoptionSegment'

            argument :id, ::Types::GlobalIDType[::Analytics::DevopsAdoption::Segment],
              required: true,
              description: "ID of the segment"

            def resolve(id:, name:, group_ids: nil, **)
              segment = ::Analytics::DevopsAdoption::Segments::UpdateService
                .new(segment: id.find, params: { name: name, group_ids: to_numeric_ids(group_ids) })
                .execute

              resolve_segment(segment)
            end
          end
        end
      end
    end
  end
end
