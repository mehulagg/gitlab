# frozen_string_literal: true

module Snippets
  # Tries to schedule a move for every snippet with repositories on the source shard
  class ScheduleBulkRepositoryShardMovesService
    include ScheduleBulkRepositoryShardMovesMethods

    private

    def repository_klass
      SnippetRepository
    end

    def container_klass
      Snippet
    end

    def container_column
      :snippet_id
    end

    def self.schedule_bulk_worker_klass
      ::SnippetScheduleBulkRepositoryShardMovesWorker
    end
  end
end
