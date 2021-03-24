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

    REINDEX_MAX_RETRY_LIMIT = 10

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

    def alias_names
      [elastic_helper.target_name] + elastic_helper.standalone_indices_proxies.map(&:index_name)
    end

    def default_index_options(alias_name:, index_name:)
      {
        refresh_interval: elastic_helper.get_settings(index_name: index_name).dig('refresh_interval'), # Use existing setting or nil for default
        number_of_replicas: Elastic::IndexSetting[alias_name].number_of_replicas,
        translog: { durability: 'request' }
      }
    end

    def initial!
      if Elastic::DataMigrationService.pending_migrations?
        # migrations may have paused indexing so we do not want to unpause when aborting the reindexing process
        abort_reindexing!('You have unapplied advanced search migrations. Please wait until it is finished', unpause_indexing: false)
        return false
      end

      # Pause indexing
      Gitlab::CurrentSettings.update!(elasticsearch_pause_indexing: true)

      unless elastic_helper.alias_exists?
        abort_reindexing!('Your Elasticsearch index must first use aliases before you can use this feature. Please recreate your index from scratch before reindexing.')
        return false
      end

      expected_free_size = alias_names.sum {|name| elastic_helper.index_size_bytes(index_name: name) } * 2
      if elastic_helper.cluster_free_size_bytes < expected_free_size
        abort_reindexing!("You should have at least #{expected_free_size} bytes of storage available to perform reindexing. Please increase the storage in your Elasticsearch cluster before reindexing.")
        return false
      end

      current_task.update!(state: :indexing_paused)

      true
    end

    def indexing_paused!
      # Create indices with custom settings
      main_index = elastic_helper.create_empty_index(with_alias: false, options: { settings: INITIAL_INDEX_OPTIONS })
      standalone_indices = elastic_helper.create_standalone_indices(with_alias: false, options: { settings: INITIAL_INDEX_OPTIONS })

      main_index.merge(standalone_indices).each do |new_index_name, alias_name|
        old_index_name = elastic_helper.target_index_name(target: alias_name)
        # Record documents count
        documents_count = elastic_helper.documents_count(index_name: old_index_name)
        # Trigger reindex
        max_slice = elastic_helper.get_settings(index_name: old_index_name).dig('number_of_shards').to_i
        task_id = elastic_helper.reindex(from: old_index_name, to: new_index_name, max_slice: max_slice, slice: 0)
        logger.info(message: "Reindex task #{task_id} from #{old_index_name} to #{new_index_name} started for slice 0.")

        current_task.subtasks.create!(
          alias_name: alias_name,
          index_name_from: old_index_name,
          index_name_to: new_index_name,
          documents_count: documents_count,
          elastic_task: task_id,
          elastic_max_slice: max_slice,
          elastic_slice: 0
        )
      end

      current_task.update!(state: :reindexing)
      true
    end

    def save_documents_count!(refresh:)
      current_task.subtasks.each do |subtask|
        elastic_helper.refresh_index(index_name: subtask.index_name_to) if refresh

        new_documents_count = elastic_helper.documents_count(index_name: subtask.index_name_to)
        subtask.update!(documents_count_target: new_documents_count)
      end
    end

    def check_task_status
      save_documents_count!(refresh: false)

      failed = 0
      not_completed = 0
      current_task.subtasks.each do |subtask|
        task_status = elastic_helper.task_status(task_id: subtask.elastic_task)
        not_completed += 1 unless task_status['completed']

        reindexing_error = task_status.dig('error', 'type')
        if reindexing_error
          message = "Task #{subtask.elastic_task} has failed with an Elasticsearch error."
          if subtask.retry_attempt < REINDEX_MAX_RETRY_LIMIT
            retry_slice(subtask, "#{message} Retrying." )
          else
            abort_reindexing!("#{message}. Retry limit reached. Aborting reindexing.", additional_logs: { elasticsearch_error_type: reindexing_error, elastic_slice: subtask.elastic_slice })
          end

          failed += 1
        end
      end

      not_completed == 0 && failed == 0
    rescue Elasticsearch::Transport::Transport::Error
      abort_reindexing!("Couldn't load task status")

      false
    end

    def retry_slice(subtask, message, additional_options = {})
      warn = {
        message: message,
        gitlab_task_id: current_task.id,
        gitlab_task_state: current_task.state,
        gitlab_subtask_id:  subtask.id,
        gitlab_subtask_slice: subtask.elastic_slice
      }.merge(additional_options)
      logger.warn(warn)

      task_id = elastic_helper.reindex(from: subtask.index_name_from, to: subtask.index_name_to, max_slice: subtask.elastic_max_slice, slice: subtask.elastic_slice)
      retry_attempt = subtask.retry_attempt + 1
      subtask.update!(elastic_task: task_id, retry_attempt: retry_attempt)
    end

    def compare_slice_totals
      save_documents_count!(refresh: true)

      totals_do_not_match = 0
      current_task.subtasks.each do |subtask|
        task = elastic_helper.task_status(task_id: subtask.elastic_task)
        response = task['response']
        if response['total'] != (response['created'] + response['updated'] + response['deleted'])
          message = "Task #{subtask.elastic_task} total is not equal to updated + created + deleted."
          if subtask.retry_attempt < REINDEX_MAX_RETRY_LIMIT
            retry_slice(subtask, "#{message} Retrying.")
          else
            abort_reindexing!("#{message} Retry limit reached. Aborting reindexing.", additional_logs: { elastic_slice: subtask.elastic_slice })
          end

          totals_do_not_match += 1
        end
      end

      totals_do_not_match == 0
    end

    def check_all_slices_submitted
      save_documents_count!(refresh: false)

      not_completed = 0
      current_task.subtasks.each do |subtask|
        next_slice = subtask.elastic_slice + 1
        if next_slice < subtask.elastic_max_slice
          # Trigger next slice and reset retry count
          task_id = elastic_helper.reindex(from: subtask.index_name_from, to: subtask.index_name_to, max_slice: subtask.elastic_max_slice, slice: next_slice)
          logger.info(message: "Reindex task #{task_id} from #{subtask.index_name_from} to #{subtask.index_name_to} started for slice #{next_slice}.")
          subtask.update!(elastic_task: task_id, elastic_slice: next_slice, retry_attempt: 0)
          not_completed += 1
        end
      end

      not_completed == 0
    end

    def compare_documents_count
      save_documents_count!(refresh: true)

      current_task.subtasks.each do |subtask|
        old_documents_count = subtask.documents_count
        new_documents_count = subtask.documents_count_target
        if old_documents_count != new_documents_count
          abort_reindexing!("Documents count is different, Count from new index: #{new_documents_count} Count from original index: #{old_documents_count}. This likely means something went wrong during reindexing.")

          return false
        end
      end

      true
    end

    def apply_default_index_options
      current_task.subtasks.each do |subtask|
        elastic_helper.update_settings(
          index_name: subtask.index_name_to,
          settings: default_index_options(alias_name: subtask.alias_name, index_name: subtask.index_name_from)
        )
      end
    end

    def switch_alias_to_new_index
      current_task.subtasks.each do |subtask|
        elastic_helper.switch_alias(from: subtask.index_name_from, to: subtask.index_name_to, alias_name: subtask.alias_name)
      end
    end

    def finalize_reindexing
      Gitlab::CurrentSettings.update!(elasticsearch_pause_indexing: false)

      current_task.update!(state: :success, delete_original_index_at: DELETE_ORIGINAL_INDEX_AFTER.from_now)
    end

    def reindexing!
      return false unless check_task_status
      return false unless compare_slice_totals
      return false unless check_all_slices_submitted
      return false unless compare_documents_count

      apply_default_index_options
      switch_alias_to_new_index
      finalize_reindexing

      true
    end

    def abort_reindexing!(reason, additional_logs: {}, unpause_indexing: true)
      error = { message: 'elasticsearch_reindex_error', error: reason, gitlab_task_id: current_task.id, gitlab_task_state: current_task.state }
      logger.error(error.merge(additional_logs))

      current_task.update!(
        state: :failure,
        error_message: reason
      )

      # Unpause indexing
      Gitlab::CurrentSettings.update!(elasticsearch_pause_indexing: false) if unpause_indexing
    end

    def logger
      @logger ||= ::Gitlab::Elasticsearch::Logger.build
    end

    def elastic_helper
      Gitlab::Elastic::Helper.default
    end
  end
end
