# frozen_string_literal: true

module EE
  module ProjectFeature
    extend ActiveSupport::Concern

    EE_FEATURES = %i(requirements security_and_compliance).freeze
    NOTES_PERMISSION_TRACKED_FIELDS = %w(issues_access_level repository_access_level merge_requests_access_level snippets_access_level).freeze

    prepended do
      set_available_features(EE_FEATURES)

      # Ensure changes to project visibility settings go to elasticsearch if the tracked field(s) change
      after_commit on: :update do
        if project.maintaining_elasticsearch?
          project.maintain_elasticsearch_update

          associations_to_update = []
          associations_to_update << 'issues' if elasticsearch_project_issues_need_updating?
          associations_to_update << 'notes' if elasticsearch_project_notes_need_updating?

          ElasticAssociationIndexerWorker.perform_async(self.project.class.name, project_id, associations_to_update) if associations_to_update.any?
        end
      end

      default_value_for :requirements_access_level, value: Featurable::ENABLED, allows_nil: false
      default_value_for :security_and_compliance_access_level, value: Featurable::PRIVATE, allows_nil: false

      private

      def elasticsearch_project_notes_need_updating?
        self.previous_changes.keys.any? { |key| NOTES_PERMISSION_TRACKED_FIELDS.include?(key) }
      end

      def elasticsearch_project_issues_need_updating?
        self.previous_changes.key?(:issues_access_level)
      end
    end
  end
end
