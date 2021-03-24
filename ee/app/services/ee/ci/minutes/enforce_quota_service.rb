# frozen_string_literal: true

module EE
  module Ci
    module Minutes
      module EnforceQuotaService
        extend ::Gitlab::Utils::Override
        include ::Gitlab::Utils::StrongMemoize
        include ::Gitlab::ExclusiveLeaseHelpers

        CHECK_INTERVAL = 5.minutes
        MINUTES_GRACE_PERIOD = 20

        override :conditionally_execute_async
        def conditionally_execute_async
          ::Gitlab::Redis::SharedState.with do |redis|
            if redis.set(quota_project_key, 1, ex: CHECK_INTERVAL, nx: true)
              ::Ci::Minutes::EnforceQuotaWorker.perform_async(project.id)
            end
          end
        end

        override :execute
        def execute
          return unless project.shared_runners_minutes_limit_enabled?
          return if project.public? # TODO: technical debt: https://gitlab.com/gitlab-org/gitlab/-/issues/325801

          if lock_namespace_check
            in_lock(lock_key, ttl: CHECK_INTERVAL - 1) do
              consumption_running_builds = 0

              running_builds_by_shared_runners.each_batch do |running_builds|
                consumption_running_builds += calculate_consumption(running_builds)
              end

              if consumption_running_builds > allowed_remaining_minutes
                drop_alive_builds!
              end
            end
          end
        rescue ::Gitlab::ExclusiveLeaseHelpers::FailedToObtainLockError
          # noop
        end

        def lock_namespace_check
          ::Gitlab::Redis::SharedState.with do |redis|
            redis.set(quota_namespace_key, 1, ex: CHECK_INTERVAL, nx: true)
          end
        end

        def quota_namespace_key
          "ci:minutes:quota:namespace:#{root_namespace.id}"
        end

        private

        # TODO: check query plans
        def running_builds_by_shared_runners
          ::Ci::Build.running.from_shared_runners.for_project(root_namespace.all_projects)
        end

        def calculate_consumption(builds)
          # TODO: ensure no N+1s
          builds.preload(:project, :runner).sum do |build|
            ::Gitlab::Ci::Minutes::BuildConsumption.new(build).amount
          end
        end

        def drop_alive_builds!
          # TODO: check query plans
          ::Ci::Build.alive.for_project(root_namespace.all_projects).each_batch do |alive_builds|
            # TODO: test that we are avoiding N+1s
            alive_builds.preload(:runner, :tags).each do |build|
              next if being_run_by_specific_runner?(build)
              next if any_matching_specific_runner?(build)

              ::Gitlab::OptimisticLocking.retry_lock(build, name: 'enforce_ci_quota') do |subject|
                subject.drop(:ci_quota_exceeded)
              end
            end
          end
        end

        def any_matching_specific_runner?(build)
          online_specific_runners.any? { |runner| runner.matches_build?(build) }
        end

        def being_run_by_specific_runner?(build)
          build.running? && !build.runner&.instance_type?
        end

        # TODO: check query plans
        def online_specific_runners
          strong_memoize(:online_runners) do
            # TODO: is there another way to avoid the deprecated scope?
            project.all_runners.with_tags.online.deprecated_specific.to_a
          end
        end

        def quota_project_key
          "ci:minutes:quota:project:#{project.id}"
        end

        def lock_key
          "ci:minutes:quota:namespace:#{root_namespace.id}:lock"
        end

        def root_namespace
          strong_memoize(:root_namespace) do
            project.root_namespace
          end
        end

        def quota
          strong_memoize(:quota) do
            ::Ci::Minutes::Quota.new(root_namespace)
          end
        end

        def allowed_remaining_minutes
          quota.total_minutes_remaining + MINUTES_GRACE_PERIOD
        end
      end
    end
  end
end
