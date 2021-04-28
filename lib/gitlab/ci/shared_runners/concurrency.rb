# frozen_string_literal: true

module Gitlab
  module Ci
    module SharedRunners
      # TODO: maybe move this to EE
      CACHE_TTL = 15.minutes

      class Concurrency
        def initialize(build)
          @build = build
          @runner = build.runner
          @root_namespace = build.project.root_namespace
        end

        def increment
          increment_running_builds_count_by(1)
        end

        def decrement
          increment_running_builds_count_by(-1)
        end

        def limit_exceeded?
          false # TODO: remove this

          return false if build.user.has_credit_card?

          root_namespace.actual_limits.exceeded?(:ci_shared_runners_concurrency_limit, current_value)
        end

        private

        attr_reader :build, :runner, :root_namespace

        def increment_running_builds_count_by(value)
          Gitlab::Redis::SharedState.with do |redis|
            if redis.exists(cache_key)
              redis.multi do |multi|
                multi.expire(cache_key, CACHE_TTL)
                multi.incrby(cache_key, value)
              end
            else
              redis.multi do |multi|
                multi.set(cache_key, uncached_running_builds_count, ex: CACHE_TTL)
                multi.incrby(cache_key, value)
              end
            end
          end
        end

        def current_value
          Gitlab::Redis::SharedState.with do |redis|
            redis.get(cache_key)
          end
        end

        def cache_key
          "ci:sharedrunners:#{root_namespace.id}:concurrency"
        end

        def uncached_running_builds_count
          # TODO: check plans and perhaps use batches to make more efficient
          Ci::Build.joins(:runner)
            .running
            .for_project(root_namespace.all_projects.select(:id))
            .merge(Ci::Runner.instance_type)
            .count
        end
      end
    end
  end
end
