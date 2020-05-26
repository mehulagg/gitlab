# frozen_string_literal: true

module ObjectPool
  class JoinWorker # rubocop:disable Scalability/IdempotentWorker
    include ApplicationWorker
    include ObjectPoolQueue

    worker_resource_boundary :cpu
    tags :no_disk_io

    # The use of pool id is deprecated. Keeping the argument allows old jobs to
    # still be performed.
    def perform(_pool_id, project_id)
      project = Project.find_by_id(project_id)
      return unless project&.pool_repository&.joinable?

      project.link_pool_repository

      Projects::HousekeepingService.new(project).execute
    end
  end
end
