# frozen_string_literal: true

module Gitlab
  module GithubImport
    module Stage
      class ImportPullRequestsWorker # rubocop:disable Scalability/IdempotentWorker
        include ApplicationWorker
        include GithubImport::Queue
        include StageMethods

        # client - An instance of Gitlab::GithubImport::Client.
        # project - An instance of Project.
        def import(client, project)
          waiter = Importer::PullRequestsImporter
            .new(project, client)
            .execute

          project.import_state.refresh_jid_expiration

          AdvanceStageWorker.perform_async(
            project.id,
            { waiter.key => waiter.jobs_remaining },
            :pull_requests_merge_by
          )
        end
      end
    end
  end
end
