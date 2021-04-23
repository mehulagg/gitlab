# frozen_string_literal: true

module Gitlab
  module Database
    module Migrations
      class Instrumentation
        attr_reader :observations, :logs

        def initialize(observers = ::Gitlab::Database::Migrations::Observers.all_observers)
          @observers = observers
          @observations = []
          @logs = []
        end

        def observe(migration, &block)
          observation = Observation.new(migration)
          observation.success = true

          exception = nil

          on_each_observer { |observer| observer.before }

          record_log(migration) do
            observation.walltime = Benchmark.realtime do
              yield
            rescue => e
              exception = e
              observation.success = false
            end
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

        def record_log(migration, &block)
          log = Log.new(migration, StringIO.new)
          logger_was = ActiveRecord::Base.logger
          ActiveRecord::Base.logger = Logger.new(log.content)

          yield

          ActiveRecord::Base.logger = logger_was
          @logs << log
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
