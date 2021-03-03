# frozen_string_literal: true

# Geo::ProjectHousekeepingService class
#
# Used for git housekeeping in Geo Secondary node
#
# Ex.
#   Geo::ProjectHousekeepingService.new(project).execute
#
module Geo
  class ProjectHousekeepingService < BaseService
    LEASE_TIMEOUT = 24.hours
    attr_reader :project
    attr_reader :pool_repository

    def initialize(project, new_repository: false)
      @project = project
      @pool_repository = project.pool_repository
      @new_repository = new_repository
    end

    def execute
      increment!
      do_housekeeping if needed?
    end

    def needed?
      new_repository? || (syncs_since_gc > 0 && period_match? && housekeeping_enabled?)
    end

    # rubocop: disable CodeReuse/ActiveRecord
    def registry
      @registry ||= Geo::ProjectRegistry.find_or_initialize_by(project_id: project.id)
    end
    # rubocop: enable CodeReuse/ActiveRecord

    def increment!
      Gitlab::Metrics.measure(:geo_increment_syncs_since_gc) do
        registry.increment_syncs_since_gc!
      end
    end

    private

    def do_housekeeping
      lease_uuid = try_obtain_lease
      return false unless lease_uuid.present?

      create_object_pool_on_secondary if create_object_pool_on_secondary?

      execute_gitlab_shell_gc(lease_uuid)
    end

    def execute_gitlab_shell_gc(lease_uuid)
      ::Projects::GitGarbageCollectWorker.perform_async(project.id, task, lease_key, lease_uuid)
    ensure
      if should_reset?
        Gitlab::Metrics.measure(:geo_reset_syncs_since_gc) do
          registry.reset_syncs_since_gc!
        end
      end
    end

    def try_obtain_lease
      Gitlab::Metrics.measure(:geo_obtain_housekeeping_lease) do
        lease = ::Gitlab::ExclusiveLease.new(lease_key, timeout: LEASE_TIMEOUT)
        lease.try_obtain
      end
    end

    def should_reset?
      syncs_since_gc >= gc_period
    end

    def lease_key
      "geo_project_housekeeping:#{project.id}"
    end

    def syncs_since_gc
      registry.syncs_since_gc
    end

    def new_repository?
      @new_repository
    end

    def should_repack?
      syncs_since_gc % full_repack_period == 0
    end

    def should_gc?
      syncs_since_gc % gc_period == 0
    end

    def should_incremental_repack?
      syncs_since_gc % repack_period == 0
    end

    def task
      return :gc                 if new_repository? || should_gc?
      return :full_repack        if should_repack?
      return :incremental_repack if should_incremental_repack?
    end

    def period_match?
      should_incremental_repack? || should_repack? || should_gc?
    end

    def housekeeping_enabled?
      Gitlab::CurrentSettings.housekeeping_enabled
    end

    def gc_period
      Gitlab::CurrentSettings.housekeeping_gc_period
    end

    def full_repack_period
      Gitlab::CurrentSettings.housekeeping_full_repack_period
    end

    def repack_period
      Gitlab::CurrentSettings.housekeeping_incremental_repack_period
    end

    def create_object_pool_on_secondary
      Geo::CreateObjectPoolService.new(pool_repository).execute
    end

    def create_object_pool_on_secondary?
      return unless ::Gitlab::Geo.secondary?
      return unless project.object_pool_missing?
      return unless pool_repository.source_project_repository.exists?

      true
    end
  end
end
