# frozen_string_literal: true

module Gitlab
  module Geo
    module LogCursor
      module Events
        class RepositoryUpdatedEvent
          include BaseEvent

          def process
            if replicable_project?
              registry.repository_updated!(event.source, scheduled_at)

              job_id = enqueue_job_if_shard_healthy(event) do
                ::Geo::ProjectSyncWorker.perform_async(
                  event.project_id,
                  sync_repository: event.repository?,
                  sync_wiki: event.wiki?
                )
              end
            end

            log_event(job_id)
          end

          private

          def log_event(job_id)
            super(
              'Repository update',
              project_id: event.project_id,
              source: event.source,
              resync_repository: registry.resync_repository,
              resync_wiki: registry.resync_wiki,
              scheduled_at: scheduled_at,
              replicable_project: replicable_project?,
              job_id: job_id)
          end

          def scheduled_at
            @scheduled_at ||= Time.now
          end
        end
      end
    end
  end
end
