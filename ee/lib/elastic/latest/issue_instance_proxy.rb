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

        # protect against missing project_feature and set visibility to PRIVATE
        # if the project_feature is missing on a project
        begin
          data['issues_access_level'] = target.project.project_feature.issues_access_level
        rescue NoMethodError => e
          Gitlab::ErrorTracking.track_exception(e, project_id: target.project_id, issue_id: target.id)
          data['issues_access_level'] = ProjectFeature::PRIVATE
        end

        data.merge(generic_attributes)
      end
    end
  end
end
