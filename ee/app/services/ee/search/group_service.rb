# frozen_string_literal: true

module EE
  module Search
    module GroupService
      extend ::Gitlab::Utils::Override

      override :elasticsearchable_scope
      def elasticsearchable_scope
        group
      end

      override :elastic_global
      def elastic_global
        false
      end

      override :elastic_projects
      def elastic_projects
        @elastic_projects ||= projects.pluck_primary_key
      end

      override :execute
      def execute
        return super unless use_elasticsearch?

        ::Gitlab::Elastic::GroupSearchResults.new(
          current_user,
          params[:search],
          elastic_projects,
          group: group,
          public_and_internal_projects: elastic_global,
          filters: { state: params[:state] }
        )
      end

      override :allowed_scopes
      def allowed_scopes
        super.tap do |scopes|
          scopes << 'epics' if ::Feature.enabled?(:epics_search) && ::License.feature_available?(:epics)

          scopes
        end
      end
    end
  end
end
