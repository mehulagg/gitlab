# frozen_string_literal: true

module Elastic
  module Latest
    class IssueInstanceProxy < ApplicationInstanceProxy
      GITLAB_MIGRATION_VERSION = '6b7304e6-c85e-44b4-b92c-fd5978c876cc'

      def as_indexed_json(options = {})
        data = {}

        # We don't use as_json(only: ...) because it calls all virtual and serialized attributes
        # https://gitlab.com/gitlab-org/gitlab/issues/349
        [:id, :iid, :title, :description, :created_at, :updated_at, :state, :project_id, :author_id, :confidential].each do |attr|
          data[attr.to_s] = safely_read_attribute_for_elasticsearch(attr)
        end

        data['assignee_id'] = safely_read_attribute_for_elasticsearch(:assignee_ids)
        data['issues_access_level'] = target.project.issues_access_level
        data['gitlab_migration_version'] = GITLAB_MIGRATION_VERSION

        data.merge(generic_attributes)
      end
    end
  end
end
