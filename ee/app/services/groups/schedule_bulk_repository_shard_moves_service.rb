# frozen_string_literal: true

module Groups
  # Tries to schedule a move for every group wiki with repositories on the source shard
  class ScheduleBulkRepositoryShardMovesService
    include ScheduleBulkRepositoryShardMovesMethods
    extend ::Gitlab::Utils::Override

    private

    override :repository_klass
    def repository_klass
      GroupWikiRepository
    end

    override :container_klass
    def container_klass
      Group
    end

    override :container_column
    def container_column
      :group_id
    end

    override :schedule_bulk_worker_klass
    def self.schedule_bulk_worker_klass
      ::Groups::ScheduleBulkRepositoryShardMovesWorker
    end
  end
end
