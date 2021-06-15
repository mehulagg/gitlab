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
        # TODO find a way to merge with ::Ci::Builds without appying `type = "Ci::Builds"` filter!
        #
        model = if ::Feature.enabled?(:ci_pending_builds_queue_source, runner, default_enabled: :yaml)
                  ::Ci::PendingBuild
                else
                  ::Ci::Build
                end

        visibility_relation = model.where(
          projects: { visibility_level: runner.visibility_levels_without_minutes_quota })

        enforce_limits_relation = model.where('EXISTS (?)', builds_check_limit)

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
