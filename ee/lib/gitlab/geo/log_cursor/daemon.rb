# frozen_string_literal: true

module Gitlab
  module Geo
    module LogCursor
      class Daemon
        VERSION = '0.2.0'.freeze
        BATCH_SIZE = 250
        SECONDARY_CHECK_INTERVAL = 60
        HEALTH_CHECK_INTERVAL = 60
        MAX_HEALTH_CHECK_FAILURES = 5

        attr_reader :options

        def initialize(options = {})
          @options = options
          @exit = false
          @health_check_failures_in_a_row = 0
        end

        def run!
          logger.debug('#run!: start')
          trap_signals

          until exit?
            # Prevent the node from processing events unless it's a secondary
            unless Geo.secondary?
              logger.debug("#run!: not a secondary, sleeping for #{SECONDARY_CHECK_INTERVAL} secs")
              sleep_break(SECONDARY_CHECK_INTERVAL)
              next
            end

            if unhealthy_for_too_long?
              logger.error("#run!: Exiting due to #{@health_check_failures_in_a_row} health check failures in a row...")
              return
            end

            lease = Lease.try_obtain_with_ttl { run_once! }
            return if exit?

            # When no new event is found sleep for a few moments
            arbitrary_sleep(lease[:ttl])
          end

          logger.debug('#run!: finish')
        end

        def run_once!
          gap_tracking.fill_gaps { |event_log| handle_single_event(event_log) }

          # Wrap this with the connection to make it possible to reconnect if
          # PGbouncer dies: https://github.com/rails/rails/issues/29189
          ActiveRecord::Base.connection_pool.with_connection do
            LogCursor::EventLogs.new.fetch_in_batches { |batch, last_id| handle_events(batch, last_id) }
          end
        end

        private

        def unhealthy_for_too_long?
          !healthy? && too_many_failures?
        end

        def healthy?
          throttle_health_check do
            count_health_check_failures_in_a_row do
              fresh_checks_healthy?
            end
          end
        end

        def too_many_failures?
          @health_check_failures_in_a_row > MAX_HEALTH_CHECK_FAILURES
        end

        def throttle_health_check(&block)
          if health_checked_recently?
            @healthy
          else
            @health_checked_at = Time.now
            @healthy = yield
          end
        end

        def health_checked_recently?
          @health_checked_at && @health_checked_at >= HEALTH_CHECK_INTERVAL.seconds.ago
        end

        def count_health_check_failures_in_a_row(&block)
          healthy = yield

          if healthy
            @health_check_failures_in_a_row = 0  # reset on success
          else
            @health_check_failures_in_a_row += 1 # increment on failure
          end

          healthy
        end

        def fresh_checks_healthy?
          health_check_service.liveness?
        end

        def health_check_service
          @health_check_service ||= ::Gitlab::HealthChecks::CheckAllService.new
        end

        def sleep_break(seconds)
          while seconds > 0
            sleep(1)
            seconds -= 1
            break if exit?
          end
        end

        def handle_events(batch, previous_batch_last_id)
          logger.info("#handle_events:", first_id: batch.first.id, last_id: batch.last.id)

          gap_tracking.previous_id = previous_batch_last_id

          batch.each do |event_log|
            gap_tracking.check!(event_log.id)

            handle_single_event(event_log)
          end
        end

        def handle_single_event(event_log)
          event = event_log.event

          # If a project is deleted, the event log and its associated event data
          # could be purged from the log. We ignore this and move along.
          unless event
            logger.warn("#handle_single_event: unknown event", event_log_id: event_log.id)
            return
          end

          unless can_replay?(event_log)
            logger.event_info(event_log.created_at, 'Skipped event', event_data(event_log))
            return
          end

          process_event(event, event_log)
        end

        def process_event(event, event_log)
          event_klass_for(event).new(event, event_log.created_at, logger).process
        rescue NoMethodError => e
          logger.error(e.message)
          raise e
        end

        def event_klass_for(event)
          event_klass_name = event.class.name.demodulize
          current_namespace = self.class.name.deconstantize
          Object.const_get("#{current_namespace}::Events::#{event_klass_name}", false)
        end

        def trap_signals
          trap(:TERM) { quit!(:term) }
          trap(:INT) { quit!(:int) }
        end

        # Safe shutdown
        def quit!(signal)
          warn("Signal #{signal} received, Exiting...")

          @exit = true
        end

        def exit?
          @exit
        end

        # rubocop: disable CodeReuse/ActiveRecord
        def can_replay?(event_log)
          return true if event_log.project_id.nil?

          # Always replay events for deleted projects
          return true unless Project.exists?(event_log.project_id)

          Gitlab::Geo.current_node&.projects_include?(event_log.project_id)
        end
        # rubocop: enable CodeReuse/ActiveRecord

        # Sleeps for the expired TTL that remains on the lease plus some random seconds.
        #
        # This allows multiple GeoLogCursors to randomly process a batch of events,
        # without favouring the shortest path (or latency).
        def arbitrary_sleep(delay)
          sleep(delay + rand(1..20) * 0.1)
        end

        def gap_tracking
          @gap_tracking ||= ::Gitlab::Geo::EventGapTracking.new(logger)
        end

        def logger
          @logger ||= Gitlab::Geo::LogCursor::Logger.new(self.class, log_level)
        end

        def log_level
          debug_logging? ? :debug : Rails.logger.level # rubocop:disable Gitlab/RailsLogger
        end

        def debug_logging?
          options[:debug]
        end

        def event_data(event_log)
          {
            event_log_id: event_log.id,
            event_id: event_log.event.id,
            event_type: event_log.event.class.name,
            project_id: event_log.project_id
          }
        end
      end
    end
  end
end
