# frozen_string_literal: true

module Gitlab
  module Elastic
    # Always prefer to use the full class namespace when specifying a
    # superclass inside a module, because autoloading can occur in a
    # different order between execution environments.
    class GroupSearchResults < Gitlab::Elastic::SearchResults
      attr_reader :group, :default_project_filter, :filters

      def initialize(current_user, query, limit_project_ids = nil, group:, public_and_internal_projects: false, default_project_filter: false, filters: {})
        @group = group
        @default_project_filter = default_project_filter
        @filters = filters

        super(current_user, query, limit_project_ids, public_and_internal_projects: public_and_internal_projects, filters: filters)
      end
    end
  end
end
