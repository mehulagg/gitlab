# frozen_string_literal: true

module Ci
  module Minutes
    class TrackLiveConsumptionService
      TTL_REMAINING_MINUTES = 15.minutes
      TTL_RUNNING_BUILDS = 5.minutes
      CONSUMPTION_THRESHOLD = -1000

      # TODO: expire cache when minutes are reset monthly
      # TODO: expire cache when minutes are updated via API or reset via controller
      # TODO: expire cache when extra_shared_runners_minutes_limit is updated

      def execute(build)
        consumption = consumption_since_last_update(build)
        return if consumption == 0 # first build update

        new_balance = ::Gitlab::Redis::SharedState.with do |redis|
          # TODO: ensure that the quota is not calculated if the key exists
          # otherwise write a separate method.
          redis.set(remaining_minutes_key, root_namespace.ci_minutes_quota.total_minutes_remaining.to_f, nx: true, ex: TTL_REMAINING_MINUTES)

          redis.incrbyfloat(remaining_minutes_key, -consumption)
        end

        if new_balance < CONSUMPTION_THRESHOLD
          build.drop(:ci_quota_exceeded)
        end
      end

      private

      def consumption_since_last_update(build)
        last_build_update = last_update(build)
        duration = Time.current.utc - last_build_update
        ::Gitlab::Ci::Minutes::BuildConsumption.new(build, duration: duration).amount
      end

      def remaining_minutes
        redis_lazy_set(remaining_minutes_key, ex: TTL_REMAINING_MINUTES) do
          root_namespace.ci_minutes_quota.total_minutes_remaining
        end
      end

      def last_update(build)
        redis_find_or_set(last_build_update_key(build), ex: TTL_RUNNING_BUILDS) do
          Time.current.utc
        end
      end

      def redis_find_or_set(key, ex:)
        ::Gitlab::Redis::SharedState.with do |redis|
          result = redis.get(key)
          next result if result

          yield.tap do |result|
            redis.set(key, result, ex: ex)
          end
        end
      end

      def last_build_update_key(build)
        "ci:minutes:builds:#{build.id}:last_update"
      end

      def remaining_minutes_key
        "ci:minutes:namespaces:#{root_namespace.id}:remaining"
      end

      def root_namespace
        @root_namespace ||= build.project.shared_runners_limit_namespace
      end

      def quota
        @quota ||= root_namespace.ci_minutes_quota
      end
    end
  end
end
