# frozen_string_literal: true

class MigrateMergeRequestsToSeparateIndex < Elastic::Migration
  include Elastic::MigrationHelper

  pause_indexing!
  batched!
  space_requirements!
  throttle_delay 1.minute

  MAX_ATTEMPTS_PER_SLICE = 30

  def migrate
    # On initial batch we only create index
    if migration_state[:slice].blank?
      reindexing_cleanup! # support retries

      log "Create standalone #{document_type_plural} index under #{new_index_name}"
      helper.create_standalone_indices(target_classes: [MergeRequest])

      options = {
        slice: 0,
        retry_attempt: 0,
        max_slices: get_number_of_shards
      }
      set_migration_state(options)

      return
    end

    retry_attempt = migration_state[:retry_attempt].to_i
    slice = migration_state[:slice]
    task_id = migration_state[:task_id]
    max_slices = migration_state[:max_slices]

    if retry_attempt >= MAX_ATTEMPTS_PER_SLICE
      fail_migration_halt_error!(retry_attempt: retry_attempt)
      return
    end

    return unless slice < max_slices

    if task_id
      log "Checking reindexing status for slice:#{slice} | task_id:#{task_id}"

      if reindexing_completed?(task_id: task_id)
        log "Reindexing is completed for slice:#{slice} | task_id:#{task_id}"

        set_migration_state(
          slice: slice + 1,
          task_id: nil,
          retry_attempt: 0, # We reset retry_attempt for a next slice
          max_slices: max_slices
        )
      else
        log "Reindexing is still in progress for slice:#{slice} | task_id:#{task_id}"
      end

      return
    end

    log "Launching reindexing for slice:#{slice} | max_slices:#{max_slices}"

    task_id = reindex(slice: slice, max_slices: max_slices)

    log "Reindexing for slice:#{slice} | max_slices:#{max_slices} is started with task_id:#{task_id}"

    set_migration_state(
      slice: slice,
      task_id: task_id,
      max_slices: max_slices
    )
  rescue StandardError => e
    log "migrate failed, increasing migration_state for slice:#{slice} retry_attempt:#{retry_attempt} error:#{e.message}"

    set_migration_state(
      slice: slice,
      task_id: nil,
      retry_attempt: retry_attempt + 1,
      max_slices: max_slices
    )

    raise e
  end

  def completed?
    helper.refresh_index(index_name: new_index_name)

    original_count = original_documents_count
    new_count = new_documents_count
    log "Checking to see if migration is completed based on index counts: original_count:#{original_count}, new_count:#{new_count}"

    original_count == new_count
  end

  def space_required_bytes
    # merge_requests index on GitLab.com takes at most 0.2% of the main index storage
    # this migration will require 5 times that value to give a buffer
    (helper.index_size_bytes * 0.010).ceil
  end

  private

  def document_type
    'merge_request'
  end

  def document_type_fields
    %w(
      type
      id
      iid
      target_branch
      source_branch
      title
      description
      created_at
      updated_at
      state
      merge_status
      source_project_id
      target_project_id
      project_id
      author_id
      visibility_level
      merge_requests_access_level
    )
  end
end
