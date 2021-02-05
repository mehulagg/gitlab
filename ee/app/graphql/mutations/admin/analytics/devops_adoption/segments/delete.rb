# frozen_string_literal: true

module Mutations
  module Admin
    module Analytics
      module DevopsAdoption
        module Segments
          class Delete < BaseMutation
            include Mixins::CommonMethods

            graphql_name 'DeleteDevopsAdoptionSegment'

            argument :id, ::Types::GlobalIDType[::Analytics::DevopsAdoption::Segment],
              required: true,
              description: "ID of the segment."

            def resolve(id:, **)
              response = ::Analytics::DevopsAdoption::Segments::DeleteService
                .new(segment: id.find, current_user: current_user)
                .execute

              { errors: errors_on_object(response.payload[:segment]) }
            end
          end
        end
      end
    end
  end
end
