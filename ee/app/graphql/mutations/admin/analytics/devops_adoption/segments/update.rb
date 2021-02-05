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
              description: "ID of the segment."

            def resolve(id:, name:, group_ids: nil, **)
              groups = GlobalID::Locator.locate_many(group_ids) if group_ids

              segment = ::Analytics::DevopsAdoption::Segments::UpdateService
                .new(current_user: current_user, segment: id.find, params: { name: name, groups: groups })
                .execute

              resolve_segment(segment)
            end
          end
        end
      end
    end
  end
end
