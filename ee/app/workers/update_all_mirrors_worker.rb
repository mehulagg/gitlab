class UpdateAllMirrorsWorker
  include ApplicationWorker
  include CronjobQueue

  LEASE_TIMEOUT = 5.minutes
  LEASE_KEY = 'update_all_mirrors'.freeze

  def perform
    lease_uuid = try_obtain_lease
    return unless lease_uuid

    schedule_mirrors!

    cancel_lease(lease_uuid)
  end

  def schedule_mirrors!
    capacity = batch_size = Gitlab::Mirror.available_capacity

    # Ignore mirrors that become due for scheduling once work begins, so we
    # can't end up in an infinite loop
    now = Time.now
    last = nil

    # Normally, this will complete in 1-2 batches. One batch will be added per
    # `batch_size` unlicensed projects in the database.
    while capacity > 0
      projects = pull_mirrors_batch(freeze_at: now, batch_size: batch_size, offset_at: last)
      break if projects.empty?

      last = projects.last.mirror_data.next_execution_timestamp

      projects.each do |project|
        next unless project.mirror?

        capacity -= 1
        project.import_schedule
        break unless capacity > 0
      end
    end
  end

  private

  def try_obtain_lease
    ::Gitlab::ExclusiveLease.new(LEASE_KEY, timeout: LEASE_TIMEOUT).try_obtain
  end

  def cancel_lease(uuid)
    ::Gitlab::ExclusiveLease.cancel(LEASE_KEY, uuid)
  end

  def pull_mirrors_batch(freeze_at:, batch_size:, offset_at: nil)
    relation = Project.mirrors_to_sync(freeze_at).reorder('project_mirror_data.next_execution_timestamp').limit(batch_size)

    relation = relation.where('next_execution_timestamp > ?', offset_at) if offset_at

    relation
  end
end
