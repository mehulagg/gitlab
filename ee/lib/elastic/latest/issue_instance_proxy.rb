# frozen_string_literal: true

module Elastic
  module Latest
    class IssueInstanceProxy < ApplicationInstanceProxy
      def as_indexed_json(options = {})
        data = {}

        # We don't use as_json(only: ...) because it calls all virtual and serialized attributes
        # https://gitlab.com/gitlab-org/gitlab/issues/349
        [:id, :iid, :title, :description, :created_at, :updated_at, :state, :project_id, :author_id, :confidential].each do |attr|
          data[attr.to_s] = safely_read_attribute_for_elasticsearch(attr)
        end

        data['assignee_id'] = safely_read_attribute_for_elasticsearch(:assignee_ids)
        data['visibility_level'] = target.project.visibility_level
        data['issues_access_level'] = safely_read_project_feature_for_elasticsearch(:issues_access_level)

        data.merge(generic_attributes)
      end

      private

      def generic_attributes
        if Elastic::DataMigrationService.migration_has_finished?(:migrate_issues_to_separate_index)
          super.except('join_field')
        else
          super
        end
      end
    end
  end
end
