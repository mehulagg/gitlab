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
            metrics.increment_queue_operation(:queue_replication_lag)

            return ::Ci::RegisterJobService::Result.new(nil, false) # rubocop:disable Cop/AvoidReturnFromBlocks
          end
        end
      end

      def builds_for_shared_runner
        # if disaster recovery is enabled, we disable quota
        if ::Feature.enabled?(:ci_queueing_disaster_recovery, runner, type: :ops, default_enabled: :yaml)
          super
        else
          enforce_minutes_based_on_cost_factors(super)
        end
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
        if traversal_ids_enabled?
          ::Namespace
            .where('namespaces.id = project_namespaces.traversal_ids[1]')
            .joins('INNER JOIN namespaces as project_namespaces ON project_namespaces.id = projects.namespace_id')
        else
          namespaces = ::Namespace.reorder(nil).where('namespaces.id = projects.namespace_id')
          ::Gitlab::ObjectHierarchy.new(namespaces, options: { skip_ordering: true }).roots
        end
      end
      # rubocop: enable CodeReuse/ActiveRecord

      def application_shared_runners_minutes
        ::Gitlab::CurrentSettings.shared_runners_minutes
      end

      def traversal_ids_enabled?
        ::Feature.enabled?(:sync_traversal_ids, default_enabled: :yaml) &&
          ::Feature.enabled?(:traversal_ids_for_quota_calculation, type: :development, default_enabled: :yaml)
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
