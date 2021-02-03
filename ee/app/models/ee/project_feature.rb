# frozen_string_literal: true

module EE
  module ProjectFeature
    extend ActiveSupport::Concern

    # When updating this array, make sure to update rubocop/cop/gitlab/feature_available_usage.rb as well.
    EE_FEATURES = %i(requirements security_and_compliance).freeze

    prepended do
      set_available_features(EE_FEATURES)

      # Ensure changes to project visibility settings go to elasticsearch if the tracked field(s) change
      after_commit on: :update do
        if project.maintaining_elasticsearch?
          project.maintain_elasticsearch_update

          ElasticAssociationIndexerWorker.perform_async(self.project.class.name, project_id, ['issues']) if elasticsearch_project_associations_need_updating?
        end
      end

      default_value_for :requirements_access_level, value: Featurable::ENABLED, allows_nil: false
      default_value_for :security_and_compliance_access_level, value: Featurable::PRIVATE, allows_nil: false

      private

      def elasticsearch_project_associations_need_updating?
        self.previous_changes.key?(:issues_access_level)
      end
    end
  end
end
