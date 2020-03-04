# frozen_string_literal: true

module Gitlab
  module JiraImport
    class BatchNotesImportWorker # rubocop:disable Scalability/IdempotentWorker
      include ApplicationWorker
      include QueueOptions
      include Gitlab::Import::DatabaseHelpers

      def perform(project_id, comments, waiter_key)
        project = Project.find(project_id)

        Gitlab::Database.bulk_insert(Note.table_name, comments)
      rescue ActiveRecord::InvalidForeignKey
        # todo: report as failed to insert to report to the user
        # It's possible the project has been deleted since scheduling this
        # job. In this case we'll just skip creating the issue.
      ensure
        JobWaiter.notify(waiter_key, project.import_state.jid) if waiter_key
      end
    end
  end
end
