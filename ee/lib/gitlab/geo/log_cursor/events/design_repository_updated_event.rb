# frozen_string_literal: true

module Gitlab
  module Geo
    module LogCursor
      module Events
        class DesignRepositoryUpdatedEvent
          include BaseEvent

          def process
            job_id =
              if replicable_design?
                registry.repository_updated!
                registry.save

                schedule_job(event)
              end

            log_event(job_id)
          end

          private

          def registry
            @registry ||= ::Geo::DesignRegistry.find_or_initialize_by(project_id: event.project_id) # rubocop: disable CodeReuse/ActiveRecord
          end

          def replicable_design?
            memoize_and_short_circuit_if_registry_is_persisted(:"replicable_design_#{event.project_id}", registry) do
              Gitlab::Geo.current_node.designs_include?(event.project_id)
            end
          end

          def schedule_job(event)
            enqueue_job_if_shard_healthy(event) do
              ::Geo::DesignRepositorySyncWorker.perform_async(event.project_id)
            end
          end

          def log_event(job_id)
            super(
              'Design repository update',
              project_id: event.project_id,
              scheduled_at: Time.now,
              replicable_design: replicable_design?,
              job_id: job_id)
          end
        end
      end
    end
  end
end
