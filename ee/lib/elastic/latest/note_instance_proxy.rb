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

        if noteable.is_a?(Issue)
          data['issue'] = {
            'assignee_id' => noteable.assignee_ids,
            'author_id' => noteable.author_id,
            'confidential' => noteable.confidential
          }
        end

        # only attempt to set project permissions if associated to a project
        # do not add the permission fields unless the `remove_permissions_data_from_notes_documents`
        # migration has completed otherwise the migration will never finish
        if target.project && Elastic::DataMigrationService.migration_has_finished?(:remove_permissions_data_from_notes_documents)
          data['visibility_level'] = target.project.visibility_level
          merge_project_feature_access_level(data, noteable)
        end

        data.merge(generic_attributes)
      end

      private

      def merge_project_feature_access_level(data, noteable)
        return unless noteable

        case noteable
        when Snippet
          data['snippets_access_level'] = safely_read_project_feature_for_elasticsearch(:snippets)
        when Commit
          data['repository_access_level'] = safely_read_project_feature_for_elasticsearch(:repository)
        when Issue, MergeRequest
          access_level_attribute = ProjectFeature.access_level_attribute(noteable)
          data[access_level_attribute.to_s] = safely_read_project_feature_for_elasticsearch(noteable)
        else
          # do nothing for other note types (DesignManagement::Design, AlertManagement::Alert, Epic, Vulnerability )
          # are indexed but not currently searchable so we will not add permission
          # data for them until the search capability is implemented
        end
      end
    end
  end
end
