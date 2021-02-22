# frozen_string_literal: true

module Mutations
  module Admin
    module Analytics
      module DevopsAdoption
        module Segments
          class BulkFindOrCreate < BaseMutation
            include Mixins::CommonMethods

            graphql_name 'BulkFindOrCreateDevopsAdoptionSegments'

            argument :namespace_ids, [::Types::GlobalIDType[::Namespace]],
                     required: true,
                     description: 'Namespace ID to set for the segment.'

            field :segments,
                  [::Types::Admin::Analytics::DevopsAdoption::SegmentType],
                  null: true,
                  description: 'Created segments after mutation.'

            def resolve(namespace_ids:, **)
              namespaces = GlobalID::Locator.locate_many(namespace_ids)

              segments = namespaces.map do |namespace|
                ::Analytics::DevopsAdoption::Segments::FindOrCreateService
                  .new(current_user: current_user, params: { namespace: namespace })
                  .execute.payload.fetch(:segment)
              end

              {
                segments: segments.select(&:persisted?),
                errors: segments.map { |segment| errors_on_object(segment) }.flatten
              }
            end
          end
        end
      end
    end
  end
end
