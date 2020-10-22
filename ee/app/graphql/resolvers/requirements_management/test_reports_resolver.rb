# frozen_string_literal: true

module Resolvers
  module RequirementsManagement
    class TestReportsResolver < BaseResolver
      argument :sort, Types::SortEnum,
               required: false,
               description: 'List test reports by sort order'

      type Types::RequirementsManagement::TestReportType, null: true

      def resolve(**args)
        # The requirement could have been loaded in batch by `BatchLoader`.
        # At this point we need the `id` of the requirement to query for test reports, so
        # make sure it's loaded and not `nil` before continuing.
        requirement = object.respond_to?(:sync) ? object.sync : object

        requirement.test_reports.order_by(args[:sort])
      end
    end
  end
end
