# frozen_string_literal: true

module Mutations
  module Admin
    module Analytics
      module DevopsAdoption
        module Segments
          class Delete < BaseMutation
            include Mixins::CommonMethods

            graphql_name 'DeleteDevopsAdoptionSegments'

            argument :ids, [::Types::GlobalIDType[::Analytics::DevopsAdoption::Segment]],
              required: true,
              description: "IDs of the segments to delete."

            def resolve(ids:, **)
              segments = GlobalID::Locator.locate_many(ids)

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
end
