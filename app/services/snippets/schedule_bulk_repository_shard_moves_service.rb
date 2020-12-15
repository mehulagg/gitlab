# frozen_string_literal: true

module Snippets
  # Tries to schedule a move for every snippet with repositories on the source shard
  class ScheduleBulkRepositoryShardMovesService
    include BaseServiceUtility

    def execute(source_storage_name, destination_storage_name = nil)
      shard = Shard.find_by_name!(source_storage_name)

      SnippetRepository.for_shard(shard).each_batch(column: :snippet_id) do |relation|
        Snippet.id_in(relation.select(:snippet_id)).each do |snippet|
          snippet.with_lock do
            next if snippet.repository_storage != source_storage_name

            storage_move = snippet.repository_storage_moves.build(
              source_storage_name: source_storage_name,
              destination_storage_name: destination_storage_name
            )

            unless storage_move.schedule
              log_info("Snippet #{snippet.full_path} (#{snippet.id}) was skipped: #{storage_move.errors.full_messages.to_sentence}")
            end
          end
        end
      end

      success
    end

    def self.enqueue(source_storage_name, destination_storage_name = nil)
      ::SnippetScheduleBulkRepositoryShardMovesWorker.perform_async(source_storage_name, destination_storage_name)
    end
  end
end
