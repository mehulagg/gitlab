module Geo
  class RepositoriesCleanUpWorker
    include ApplicationWorker
    include GeoQueue
    include Gitlab::ShellAdapter
    include ExclusiveLeaseGuard

    BATCH_SIZE = 250
    LEASE_TIMEOUT = 60.minutes

    def perform(geo_node_id)
      # Prevent multiple Sidekiq workers from performing repositories clean up
      try_obtain_lease do
        geo_node = GeoNode.find(geo_node_id)

        restricted_project_ids = geo_node.restricted_project_ids
        return unless restricted_project_ids

        Project.where.not(id: restricted_project_ids).find_in_batches(batch_size: BATCH_SIZE) do |batch|
          batch.each do |project|
            clean_up_repositories(project)
          end
        end
      end
    rescue ActiveRecord::RecordNotFound => e
      log_error('Could not find Geo node, skipping repositories clean up', geo_node_id: geo_node_id, error: e)
    end

    private

    def clean_up_repositories(project)
      # There is a possibility project does not have repository or wiki
      return true unless gitlab_shell.exists?(project.repository_storage_path, "#{project.disk_path}.git")

      job_id = ::GeoRepositoryDestroyWorker.perform_async(project.id, project.name, project.full_path)

      if job_id
        log_info('Repository cleaned up', project_id: project.id, full_path: project.full_path, job_id: job_id)
      else
        log_error('Could not clean up repository', project_id: project.id, full_path: project.full_path)
      end
    end

    def lease_timeout
      LEASE_TIMEOUT
    end

    def log_info(message, params = {})
      Gitlab::Geo::Logger.info({ class: self.class.name, message: message }.merge(params))
    end

    def log_error(message, params = {})
      Gitlab::Geo::Logger.error({ class: self.class.name, message: message }.merge(params))
    end
  end
end
