# frozen_string_literal: true

module Gitlab
  module Geo
    module LogCursor
      module Events
        class RepositoryDeletedEvent
          include BaseEvent

          def process
            job_id = nil

            unless registry_exists?
              job_id = destroy_repository
            end

            log_event(job_id)
          end

          private

          def destroy_repository
            # Must always schedule, regardless of shard health
            ::Geo::RepositoryDestroyService.new(
              event.project_id,
              event.deleted_project_name,
              event.deleted_path,
              event.repository_storage_name
            ).async_execute
          end

          def log_event(job_id)
            super(
              'Deleted project',
              project_id: event.project_id,
              repository_storage_name: event.repository_storage_name,
              disk_path: event.deleted_path,
              skippable: registry_exists?,
              job_id: job_id)
          end
        end
      end
    end
  end
end
