module Gitlab
  module Geo
    module LogCursor
      module Events
        class RepositoryCreatedEvent
          include BaseEvent

          def process
            log_event
            registry.save!

            enqueue_job_if_shard_healthy(event) do
              ::Geo::ProjectSyncWorker.perform_async(event.project_id, Time.now)
            end
          end

          private

          def registry
            @registry ||= find_or_initialize_registry(
              resync_repository: true,
              resync_wiki: event.wiki_path.present?)
          end

          def log_event
            logger.event_info(
              created_at,
              'Repository created',
              project_id: event.project_id,
              repo_path: event.repo_path,
              wiki_path: event.wiki_path,
              resync_repository: registry.resync_repository,
              resync_wiki: registry.resync_wiki)
          end
        end
      end
    end
  end
end
