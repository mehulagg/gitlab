# frozen_string_literal: true

module Elastic
  class ClusterReindexingService
    include Gitlab::Utils::StrongMemoize

    INITIAL_INDEX_OPTIONS = { # Optimized for writes
        refresh_interval: '10s',
        number_of_replicas: 0,
        translog: { durability: 'async' }
    }.freeze

    DELETE_ORIGINAL_INDEX_AFTER = 14.days

    def execute
      case current_task.state.to_sym
      when :initial
        initial!
      when :indexing_paused
        indexing_paused!
      when :reindexing
        reindexing!
      end
    end

    def current_task
      strong_memoize(:elastic_current_task) do
        Elastic::ReindexingTask.current
      end
    end

    private

    def default_index_options
      {
        refresh_interval: nil, # Change it back to the default
        number_of_replicas: Gitlab::CurrentSettings.elasticsearch_replicas,
        translog: { durability: 'request' }
      }
    end

    def initial!
      # Pause indexing
      Gitlab::CurrentSettings.update!(elasticsearch_pause_indexing: true)

      unless elastic_helper.alias_exists?
        abort_reindexing!('Your Elasticsearch index must first use aliases before you can use this feature. Please recreate your index from scratch before reindexing.')
        return false
      end

      expected_free_size = elastic_helper.index_size_bytes * 2
      if elastic_helper.cluster_free_size_bytes < expected_free_size
        abort_reindexing!("You should have at least #{expected_free_size} bytes of storage available to perform reindexing. Please increase the storage in your Elasticsearch cluster before reindexing.")
        return false
      end

      current_task.update!(state: :indexing_paused)

      true
    end

    def indexing_paused!
      # Create an index with custom settings
      index_name = elastic_helper.create_empty_index(with_alias: false, options: { settings: INITIAL_INDEX_OPTIONS })

      # Record documents count
      documents_count = elastic_helper.documents_count

      # Trigger reindex
      task_id = elastic_helper.reindex(to: index_name)

      current_task.update!(
        index_name_from: elastic_helper.target_index_name,
        index_name_to: index_name,
        documents_count: documents_count,
        elastic_task: task_id,
        state: :reindexing
      )

      true
    end

    def save_documents_count!(refresh:)
      elastic_helper.refresh_index(index_name: current_task.index_name_to) if refresh

      new_documents_count = elastic_helper.documents_count(index_name: current_task.index_name_to)
      current_task.update!(documents_count_target: new_documents_count)
    end

    def check_task_status
      save_documents_count!(refresh: false)

      task_status = elastic_helper.task_status(task_id: current_task.elastic_task)
      return false unless task_status['completed']

      reindexing_error = task_status.dig('error', 'type')
      if reindexing_error
        abort_reindexing!("Task #{current_task.elastic_task} has failed with Elasticsearch error.", additional_logs: { elasticsearch_error_type: reindexing_error })
        return false
      end

      true
    rescue Elasticsearch::Transport::Transport::Error
      abort_reindexing!("Couldn't load task status")

      false
    end

    def compare_documents_count
      save_documents_count!(refresh: true)

      old_documents_count = current_task.documents_count
      new_documents_count = current_task.documents_count_target
      if old_documents_count != new_documents_count
        abort_reindexing!("Documents count is different, Count from new index: #{new_documents_count} Count from original index: #{old_documents_count}. This likely means something went wrong during reindexing.")
        return false
      end

      true
    end

    def apply_default_index_options
      elastic_helper.update_settings(index_name: current_task.index_name_to, settings: default_index_options)
    end

    def switch_alias_to_new_index
      elastic_helper.switch_alias(to: current_task.index_name_to)
    end

    def finalize_reindexing
      Gitlab::CurrentSettings.update!(elasticsearch_pause_indexing: false)

      current_task.update!(state: :success, delete_original_index_at: DELETE_ORIGINAL_INDEX_AFTER.from_now)
    end

    def reindexing!
      return false unless check_task_status
      return false unless compare_documents_count

      apply_default_index_options
      switch_alias_to_new_index
      finalize_reindexing

      true
    end

    def abort_reindexing!(reason, additional_logs: {})
      error = { message: 'elasticsearch_reindex_error', error: reason, elasticsearch_task_id: current_task.elastic_task, gitlab_task_id: current_task.id, gitlab_task_state: current_task.state }
      logger.error(error.merge(additional_logs))

      current_task.update!(
        state: :failure,
        error_message: reason
      )

      # Unpause indexing
      Gitlab::CurrentSettings.update!(elasticsearch_pause_indexing: false)
    end

    def logger
      @logger ||= ::Gitlab::Elasticsearch::Logger.build
    end

    def elastic_helper
      Gitlab::Elastic::Helper.default
    end
  end
end
