# frozen_string_literal: true

module Gitlab
  module JiraImport
    module Stage
      class ImportNotesWorker # rubocop:disable Scalability/IdempotentWorker
        include Gitlab::JiraImport::ImportWorker

        private

        def import(project)
          jobs_waiter = Gitlab::JiraImport::NotesImporter.new(project).execute

          project.import_state.refresh_jid_expiration

          Gitlab::JiraImport::AdvanceStageWorker.perform_async(project.id, { jobs_waiter.key => jobs_waiter.jobs_remaining }, :finish)
        end
      end
    end
  end
end
