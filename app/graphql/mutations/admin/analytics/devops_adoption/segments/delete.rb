# frozen_string_literal: true

module Mutations
  module Admin
    module Analytics
      module DevopsAdoption
        module Segments
          class Delete < BaseMutation
            include Mixins::RequireAdminPermission

            graphql_name 'DeleteDevopsAdoptionSegment'

            argument :id, ::Types::GlobalIDType[::Analytics::DevopsAdoption::Segment],
              required: true,
              description: "ID of the segment"

            def resolve(id:, **)
              id.find.destroy

              {
                errors: []
              }
            end
          end
        end
      end
    end
  end
end
