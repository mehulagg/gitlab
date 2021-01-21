# frozen_string_literal: true

module EE
  module Ci
    # RegisterJobService EE mixin
    #
    # This module is intended to encapsulate EE-specific service logic
    # and be included in the `RegisterJobService` service
    module RegisterJobService
      extend ActiveSupport::Concern
      extend ::Gitlab::Utils::Override

      def execute(params = {})
        db_all_caught_up = ::Gitlab::Database::LoadBalancing::Sticking.all_caught_up?(:runner, runner.id)

        super.tap do |result|
          # Since we execute this query against replica it might lead to false-positive
          # We might receive the positive response: "hi, we don't have any more builds for you".
          # This might not be true. If our DB replica is not up-to date with when runner event was generated
          # we might still have some CI builds to be picked. Instead we should say to runner:
          # "Hi, we don't have any more builds now,  but not everything is right anyway, so try again".
          # Runner will retry, but again, against replica, and again will check if replication lag did catch-up.
          if !db_all_caught_up && !result.build
            return ::Ci::RegisterJobService::Result.new(nil, false) # rubocop:disable Cop/AvoidReturnFromBlocks
          end
        end
      end

      def builds_for_shared_runner
        return super unless shared_runner_build_limits_feature_enabled?

        enforce_minutes_based_on_cost_factors(super)
      end

      # rubocop: disable CodeReuse/ActiveRecord
      def enforce_minutes_based_on_cost_factors(relation)
        visibility_relation = ::Ci::Build.where(
          projects: { visibility_level: runner.visibility_levels_without_minutes_quota })

        enforce_limits_relation = ::Ci::Build.where('EXISTS (?)', builds_check_limit)

        relation.merge(visibility_relation.or(enforce_limits_relation))
      end
      # rubocop: enable CodeReuse/ActiveRecord

      # rubocop: disable CodeReuse/ActiveRecord
      def builds_check_limit
        all_namespaces
          .joins('LEFT JOIN namespace_statistics ON namespace_statistics.namespace_id = namespaces.id')
          .where('COALESCE(namespaces.shared_runners_minutes_limit, ?, 0) = 0 OR ' \
                 'COALESCE(namespace_statistics.shared_runners_seconds, 0) < ' \
                 'COALESCE('\
                   '(namespaces.shared_runners_minutes_limit + COALESCE(namespaces.extra_shared_runners_minutes_limit, 0)), ' \
                   '(? + COALESCE(namespaces.extra_shared_runners_minutes_limit, 0)), ' \
                  '0) * 60',
                application_shared_runners_minutes, application_shared_runners_minutes)
          .select('1')
      end
      # rubocop: enable CodeReuse/ActiveRecord

      # rubocop: disable CodeReuse/ActiveRecord
      def all_namespaces
        namespaces = ::Namespace.reorder(nil).where('namespaces.id = projects.namespace_id')
        ::Gitlab::ObjectHierarchy.new(namespaces).roots
      end
      # rubocop: enable CodeReuse/ActiveRecord

      def application_shared_runners_minutes
        ::Gitlab::CurrentSettings.shared_runners_minutes
      end

      def shared_runner_build_limits_feature_enabled?
        ENV['DISABLE_SHARED_RUNNER_BUILD_MINUTES_LIMIT'].to_s != 'true'
      end

      override :pre_assign_runner_checks
      def pre_assign_runner_checks
        super.merge({
          secrets_provider_not_found: -> (build, _) { build.ci_secrets_management_available? && build.secrets? && !build.secrets_provider? }
        })
      end
    end
  end
end
