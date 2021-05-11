# frozen_string_literal: true

module Mutations
  module Analytics
    module DevopsAdoption
      module Segments
        class Delete < BaseMutation
          include Mixins::CommonMethods

          graphql_name 'DeleteDevopsAdoptionSegment'

          description '**BETA** This endpoint is subject to change without notice.'

          argument :id, [::Types::GlobalIDType[::Analytics::DevopsAdoption::Segment]],
                   required: true,
                   description: 'One or many IDs of the segments to delete.'

          def resolve(id:, **)
            segments = GlobalID::Locator.locate_many(id)

            with_authorization_handler do
              service = ::Analytics::DevopsAdoption::Segments::BulkDeleteService
                .new(segments: segments, current_user: current_user)

              response = service.execute

              errors = response.payload[:segments].sum { |segment| errors_on_object(segment) }

              { errors: errors }
            end
          end
        end
      end
    end
  end
end
