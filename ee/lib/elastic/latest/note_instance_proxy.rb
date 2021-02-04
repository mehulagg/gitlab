# frozen_string_literal: true

module Elastic
  module Latest
    class NoteInstanceProxy < ApplicationInstanceProxy
      delegate :noteable, to: :target

      def as_indexed_json(options = {})
        data = {}

        # We don't use as_json(only: ...) because it calls all virtual and serialized attributtes
        # https://gitlab.com/gitlab-org/gitlab/issues/349
        [:id, :note, :project_id, :noteable_type, :noteable_id, :created_at, :updated_at, :confidential].each do |attr|
          data[attr.to_s] = safely_read_attribute_for_elasticsearch(attr)
        end

        if for_issue?
          data['issue'] = {
            'assignee_id' => noteable.assignee_ids,
            'author_id' => noteable.author_id,
            'confidential' => noteable.confidential
          }
          data['issues_access_level'] = safely_read_project_feature_for_elasticsearch(:issues_access_level)
        elsif for_snippet?
          data['snippets_access_level'] = safely_read_project_feature_for_elasticsearch(:snippets_access_level)
        elsif for_merge_request?
          data['merge_requests_access_level'] = safely_read_project_feature_for_elasticsearch(:merge_requests_access_level)
        elsif for_commit?
          data['repository_access_level'] = safely_read_project_feature_for_elasticsearch(:repository_access_level)
        end

        data['visibility_level'] = target.project.visibility_level

        data.merge(generic_attributes)
      end
    end
  end
end
