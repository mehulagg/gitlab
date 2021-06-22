# frozen_string_literal: true

class StuckCiJobsWorker # rubocop:disable Scalability/IdempotentWorker
  include ApplicationWorker

  sidekiq_options retry: 3
  include CronjobQueue # rubocop:disable Scalability/CronWorkerContext

  feature_category :continuous_integration
  worker_resource_boundary :cpu
  idempotent!

  EXCLUSIVE_LEASE_KEY = 'stuck_ci_builds_worker_lease'

  def perform
    return unless try_obtain_lease

    Gitlab::AppLogger.info "#{self.class}: Cleaning stuck builds"

    Ci::StuckBuilds::DropService.new.execute

    remove_lease
  end

  private

  def try_obtain_lease
    @uuid = Gitlab::ExclusiveLease.new(EXCLUSIVE_LEASE_KEY, timeout: 30.minutes).try_obtain
  end

  def remove_lease
    Gitlab::ExclusiveLease.cancel(EXCLUSIVE_LEASE_KEY, @uuid)
  end
end
