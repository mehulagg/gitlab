# frozen_string_literal: true

module Gitlab
  module Geo
    module LogCursor
      module Events
        module BaseEvent
          include Utils::StrongMemoize

          def initialize(event, created_at, logger)
            @event = event
            @created_at = created_at
            @logger = logger
          end

          private

          attr_reader :event, :created_at, :logger

          # rubocop: disable CodeReuse/ActiveRecord
          def registry
            @registry ||= ::Geo::ProjectRegistry.find_or_initialize_by(project_id: event.project_id)
          end
          # rubocop: enable CodeReuse/ActiveRecord

          def registry_exists?
            registry.new_record?
          end

          def healthy_shard_for?(event)
            return true unless event.respond_to?(:project)

            Gitlab::ShardHealthCache.healthy_shard?(event.project.repository_storage)
          end

          def enqueue_job_if_shard_healthy(event)
            yield if healthy_shard_for?(event)
          end

          def replicable_project?
            memoize_and_short_circuit_if_registry_is_persisted(:"replicable_project_#{event.project_id}", registry) do
              Gitlab::Geo.current_node.projects_include?(event.project_id)
            end
          end

          def memoize_and_short_circuit_if_registry_is_persisted(memoize_key, registry, &block)
            strong_memoize(memoize_key) do
              # If a registry exists, then it *should* be replicated. The
              # registry will be removed by the delete event or
              # RegistryConsistencyWorker if it should no longer be replicated.
              #
              # This early exit helps keep event processing efficient especially
              # for repository updates which are a large proportion of events.
              next true if registry.persisted?

              yield
            end
          end

          def log_event(message, params = {})
            logger.event_info(
              created_at,
              message,
              params.merge(event_id: event.id)
            )
          end
        end
      end
    end
  end
end
