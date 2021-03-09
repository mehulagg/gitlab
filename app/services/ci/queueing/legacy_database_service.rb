# frozen_string_literal: true

module Ci
  module Queueing
    class LegacyDatabaseService < Queueing::BaseService
      def enqueue(build)
        runner.pick_build!(build)
      end

      def dequeue_each(params, &blk)
        builds =
          if runner.instance_type?
            builds_for_shared_runner
          elsif runner.group_type?
            builds_for_group_runner
          else
            builds_for_project_runner
          end

        # pick builds that does not have other tags than runner's one
        builds = builds.matches_tag_ids(runner.tags.ids)

        # pick builds that have at least one tag
        unless runner.run_untagged?
          builds = builds.with_any_tags
        end

        # pick builds that older than specified age
        if params.key?(:job_age)
          builds = builds.queued_before(params[:job_age].seconds.ago)
        end

        if Feature.enabled?(:ci_register_job_service_one_by_one, runner)
          build_ids = builds.pluck(:id)

          metrics.observe_queue_size(-> { build_ids.size })

          build_ids.each do |build_id|
            yield Ci::Build.find(build_id)
          end
        else
          metrics.observe_queue_size(-> { builds.to_a.size })

          builds.each(&blk)
        end
      end

      def queue_valid?
        true
      end

      def self.matching?(runner)
        true
      end

      private

      # rubocop: disable CodeReuse/ActiveRecord
      def builds_for_shared_runner
        new_builds.
          # don't run projects which have not enabled shared runners and builds
          joins(:project).where(projects: { shared_runners_enabled: true, pending_delete: false })
          .joins('LEFT JOIN project_features ON ci_builds.project_id = project_features.project_id')
          .where('project_features.builds_access_level IS NULL or project_features.builds_access_level > 0').

        # Implement fair scheduling
        # this returns builds that are ordered by number of running builds
        # we prefer projects that don't use shared runners at all
        joins("LEFT JOIN (#{running_builds_for_shared_runners.to_sql}) AS project_builds ON ci_builds.project_id=project_builds.project_id")
          .order(Arel.sql('COALESCE(project_builds.running_builds, 0) ASC'), 'ci_builds.id ASC')
      end
      # rubocop: enable CodeReuse/ActiveRecord

      # rubocop: disable CodeReuse/ActiveRecord
      def builds_for_project_runner
        new_builds.where(project: runner.projects.without_deleted.with_builds_enabled).order('id ASC')
      end
      # rubocop: enable CodeReuse/ActiveRecord

      # rubocop: disable CodeReuse/ActiveRecord
      def builds_for_group_runner
        # Workaround for weird Rails bug, that makes `runner.groups.to_sql` to return `runner_id = NULL`
        groups = ::Group.joins(:runner_namespaces).merge(runner.runner_namespaces)

        hierarchy_groups = Gitlab::ObjectHierarchy.new(groups).base_and_descendants
        projects = Project.where(namespace_id: hierarchy_groups)
          .with_group_runners_enabled
          .with_builds_enabled
          .without_deleted
        new_builds.where(project: projects).order('id ASC')
      end
      # rubocop: enable CodeReuse/ActiveRecord

      # rubocop: disable CodeReuse/ActiveRecord
      def running_builds_for_shared_runners
        Ci::Build.running.where(runner: Ci::Runner.instance_type)
          .group(:project_id).select(:project_id, 'count(*) AS running_builds')
      end
      # rubocop: enable CodeReuse/ActiveRecord

      def new_builds
        builds = Ci::Build.pending.unstarted
        builds = builds.ref_protected if runner.ref_protected?
        builds
      end
    end
  end
end

Ci::Queueing::LegacyDatabaseService.prepend_if_ee('EE::Ci::Queueing::LegacyDatabaseService')
