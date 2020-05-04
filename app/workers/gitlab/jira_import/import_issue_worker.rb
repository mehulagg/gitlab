# frozen_string_literal: true

module Gitlab
  module JiraImport
    class ImportIssueWorker # rubocop:disable Scalability/IdempotentWorker
      include ApplicationWorker
      include NotifyUponDeath
      include Gitlab::JiraImport::QueueOptions
      include Gitlab::Import::DatabaseHelpers

      def perform(project_id, jira_issue_id, issue_attributes, waiter_key)
        issue_id = create_issue(issue_attributes, project_id)
        JiraImport.cache_issue_mapping(issue_id, jira_issue_id, project_id)
      rescue => ex
        # Todo: Record jira issue id(or better jira issue key),
        # so that we can report the list of failed to import issues to the user
        # see https://gitlab.com/gitlab-org/gitlab/-/issues/211653
        #
        # It's possible the project has been deleted since scheduling this
        # job. In this case we'll just skip creating the issue.
        Gitlab::ErrorTracking.track_exception(ex, project_id: project_id)
        JiraImport.increment_issue_failures(project_id)
      ensure
        # ensure we notify job waiter that the job has finished
        JobWaiter.notify(waiter_key, jid) if waiter_key
      end

      private

      def create_issue(issue_attributes, project_id)
        label_ids = issue_attributes.delete('label_ids')
        issue_id = insert_and_return_id(issue_attributes, Issue)

        label_issue(project_id, issue_id, label_ids)

        issue_id
      end

      def label_issue(project_id, issue_id, label_ids)
        label_link_attrs = label_ids.to_a.map do |label_id|
          build_label_attrs(issue_id, label_id.to_i)
        end

        import_label_id = JiraImport.get_import_label_id(project_id)
        return unless import_label_id

        label_link_attrs << build_label_attrs(issue_id, import_label_id.to_i)

        Gitlab::Database.bulk_insert(LabelLink.table_name, label_link_attrs)
      end

      def build_label_attrs(issue_id, label_id)
        time = Time.now
        {
          label_id: label_id,
          target_id: issue_id,
          target_type: 'Issue',
          created_at: time,
          updated_at: time
        }
      end
    end
  end
end
