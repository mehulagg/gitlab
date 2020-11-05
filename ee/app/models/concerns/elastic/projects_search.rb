# frozen_string_literal: true

module Elastic
  module ProjectsSearch
    extend ActiveSupport::Concern

    include ApplicationVersionedSearch

    ELASTICSEARCH_PERMISSION_TRACKED_FIELDS = %w(issues_access_level visibility_level).freeze

    included do
      extend ::Gitlab::Utils::Override

      def use_elasticsearch?
        ::Gitlab::CurrentSettings.elasticsearch_indexes_project?(self)
      end

      override :maintain_elasticsearch_create
      def maintain_elasticsearch_create
        ::Elastic::ProcessInitialBookkeepingService.track!(self)
      end

      override :maintain_elasticsearch_update
      def maintain_elasticsearch_update
        super

        ::Elastic::ProcessBookkeepingService.track!(self.issues) if elasticsearch_project_issues_need_updating?
      end

      override :maintain_elasticsearch_destroy
      def maintain_elasticsearch_destroy
        ElasticDeleteProjectWorker.perform_async(self.id, self.es_id)
      end
    end

    private

    def elasticsearch_project_issues_need_updating?
      # track changes to project visibility settings in addition to visibility level for project
      changed_fields = self.project_feature.previous_changes.keys + self.previous_changes.keys
      changed_fields && (changed_fields & ELASTICSEARCH_PERMISSION_TRACKED_FIELDS).any?
    end
  end
end
