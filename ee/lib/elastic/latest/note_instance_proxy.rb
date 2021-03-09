# frozen_string_literal: true

module Elastic
  module Latest
    class NoteInstanceProxy < ApplicationInstanceProxy
      delegate :noteable, :noteable_type, to: :target

      def as_indexed_json(options = {})
        # Notes on commits should return the commit object when `notable` is called. However, `noteable` can be null
        # when a commit has been deleted so an error is raised to alert the caller that the document should be deleted
        # from the index.
        raise Elastic::Latest::DocumentShouldBeDeletedFromIndexError.new(target.class.name, target.id) if noteable_type == 'Commit' && noteable.nil?

        data = {}

        # We don't use as_json(only: ...) because it calls all virtual and serialized attributes
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

        # do not add the permission fields unless the `remove_permissions_data_from_notes_documents`
        # migration has completed otherwise the migration will never finish
        if Elastic::DataMigrationService.migration_has_finished?(:remove_permissions_data_from_notes_documents)
          data['visibility_level'] = target.project&.visibility_level || Gitlab::VisibilityLevel::PRIVATE
          merge_project_feature_access_level(data)
        end

        data.merge(generic_attributes)
      end

      private

      def merge_project_feature_access_level(data)
        return unless noteable_type

        case noteable_type
        when 'Snippet'
          data['snippets_access_level'] = safely_read_project_feature_for_elasticsearch(:snippets)
        when 'Commit'
          data['repository_access_level'] = safely_read_project_feature_for_elasticsearch(:repository)
        when 'Issue', 'MergeRequest'
          klass = noteable_type.constantize
          access_level_attribute = ProjectFeature.access_level_attribute(klass)
          data[access_level_attribute.to_s] = safely_read_project_feature_for_elasticsearch(klass)
        else
          # do nothing for other note types (DesignManagement::Design, AlertManagement::Alert, Epic, Vulnerability )
          # are indexed but not currently searchable so we will not add permission
          # data for them until the search capability is implemented
        end
      end
    end
  end
end
