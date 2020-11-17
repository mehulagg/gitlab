# frozen_string_literal: true

module Resolvers
  module RequirementsManagement
    class RequirementsResolver < BaseResolver
      include LooksAhead

      type ::Types::RequirementsManagement::RequirementType.connection_type, null: true

      argument :iid, GraphQL::ID_TYPE,
               required: false,
               description: 'IID of the requirement, e.g., "1"'

      argument :iids, [GraphQL::ID_TYPE],
               required: false,
               description: 'List of IIDs of requirements, e.g., [1, 2]'

      argument :sort, Types::SortEnum,
               required: false,
               description: 'List requirements by sort order'

      argument :state, Types::RequirementsManagement::RequirementStateEnum,
               required: false,
               description: 'Filter requirements by state'

      argument :search, GraphQL::STRING_TYPE,
               required: false,
               description: 'Search query for requirement title'

      argument :author_username, [GraphQL::STRING_TYPE],
               required: false,
               description: 'Filter requirements by author username'

      def resolve_with_lookahead(**args)
        # The project could have been loaded in batch by `BatchLoader`.
        # At this point we need the `id` of the project to query for issues, so
        # make sure it's loaded and not `nil` before continuing.
        project = object.respond_to?(:sync) ? object.sync : object
        return ::RequirementsManagement::Requirement.none if project.nil?

        args[:project_id] = project.id
        args[:iids] ||= [args[:iid]].compact

        apply_lookahead(find_requirements(args))
      end

      private

      def preloads
        {
          last_test_report_manually_created: [:test_reports],
          last_test_report_state: [:test_reports, { test_reports: [:build] }]
        }
      end

      def find_requirements(args)
        ::RequirementsManagement::RequirementsFinder.new(context[:current_user], args).execute
      end
    end
  end
end
