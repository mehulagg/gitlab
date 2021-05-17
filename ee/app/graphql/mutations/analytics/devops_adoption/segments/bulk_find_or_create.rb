# frozen_string_literal: true

module Mutations
  module Analytics
    module DevopsAdoption
      module Segments
        class BulkFindOrCreate < BaseMutation
          include Mixins::CommonMethods

          graphql_name 'BulkFindOrCreateDevopsAdoptionSegments'

          description '**BETA** This endpoint is subject to change without notice.'

          argument :namespace_ids, [::Types::GlobalIDType[::Namespace]],
                   required: true,
                   description: 'List of Namespace IDs for the segments.'

          field :segments,
                [::Types::Admin::Analytics::DevopsAdoption::SegmentType],
                null: true,
                description: 'Created segments after mutation.'

          def resolve(namespace_ids:, **)
            namespaces = GlobalID::Locator.locate_many(namespace_ids)

            with_authorization_handler do
              service = ::Analytics::DevopsAdoption::Segments::BulkFindOrCreateService
                .new(current_user: current_user, params: { namespaces: namespaces })

              segments = service.execute.payload.fetch(:segments)

              {
                segments: segments.select(&:persisted?),
                errors: segments.sum { |segment| errors_on_object(segment) }
              }
            end
          end
        end
      end
    end
  end
end
