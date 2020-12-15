# frozen_string_literal: true

module Projects
  # Tries to schedule a move for every project with repositories on the source shard
  class ScheduleBulkRepositoryShardMovesService
    include ScheduleBulkRepositoryShardMovesMethods

    private

    def repository_klass
      ProjectRepository
    end

    def container_klass
      Project
    end

    def container_column
      :project_id
    end

    def self.schedule_bulk_worker_klass
      ::ProjectScheduleBulkRepositoryShardMovesWorker
    end
  end
end
