# frozen_string_literal: true

module Gitlab
  module Database
    module Migrations
      Observation = Struct.new(
        :migration,
        :walltime,
        :success,
        :total_database_size_change
      )

      class Instrumentation
        attr_reader :observations

        def initialize(observers = ::Gitlab::Database::Migrations::Observers.all_observers)
          @observers = observers
          @observations = []
        end

        def observe(migration, &block)
          observation = Observation.new(migration)
          observation.success = true

          exception = nil

          on_each_observer { |observer| observer.before }

          observation.walltime = Benchmark.realtime do
            yield
          rescue => e
            exception = e
            observation.success = false
          end

          on_each_observer { |observer| observer.after }
          on_each_observer { |observer| observer.record(observation) }

          record_observation(observation)

          raise exception if exception

          observation
        end

        private

        attr_reader :observers

        def record_observation(observation)
          @observations << observation
        end

        def on_each_observer(&block)
          observers.each do |observer|
            yield observer
          rescue => e
            Gitlab::AppLogger.error("Migration observer #{observer.class} failed with: #{e}")
          end
        end
      end
    end
  end
end
