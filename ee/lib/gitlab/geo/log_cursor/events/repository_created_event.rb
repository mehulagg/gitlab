# frozen_string_literal: true

module Gitlab
  module Geo
    module LogCursor
      module Events
        class RepositoryCreatedEvent
          include BaseEvent

          def process
            if replicable_project?
              registry.repository_created!(event)

              job_id = nil

              enqueue_job_if_shard_healthy(event) do
                job_id = ::Geo::ProjectSyncWorker.perform_async(event.project_id, sync_repository: true, sync_wiki: true)
              end
            end

            log_event(job_id)
          end

          private

          def log_event(job_id)
            super(
              'Repository created',
              project_id: event.project_id,
              repo_path: event.repo_path,
              wiki_path: event.wiki_path,
              resync_repository: registry.resync_repository,
              resync_wiki: registry.resync_wiki,
              replicable_project: replicable_project?,
              job_id: job_id)
          end
        end
      end
    end
  end
end
