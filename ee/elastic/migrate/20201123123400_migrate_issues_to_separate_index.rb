# frozen_string_literal: true

class MigrateIssuesToSeparateIndex < Elastic::Migration
  pause_indexing!
  batched!
  throttle_delay 1.minute

  MAX_ATTEMPTS = 30

  FIELDS = %w(
    type
    id
    iid
    title
    description
    created_at
    updated_at
    state
    project_id
    author_id
    confidential
    assignee_id
    visibility_level
    issues_access_level
  ).freeze

  def migrate
    # On initial batch we only create index
    if migration_state[:slice].blank?
      cleanup # support retries

      log "Create standalone issues index under #{issues_index_name}"
      helper.create_standalone_indices(target_classes: [Issue])

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
    max_slices = migration_state[:max_slices]

    if retry_attempt >= MAX_ATTEMPTS
      fail_migration_halt_error!(retry_attempt: retry_attempt)
      return
    end

    if slice < max_slices
      log "Launching reindexing for slice:#{slice} | max_slices:#{max_slices}"

      response = reindex(slice: slice, max_slices: max_slices)
      process_response(response)

      log "Reindexing for slice:#{slice} | max_slices:#{max_slices} is completed with #{response.to_json}"

      set_migration_state(
        slice: slice + 1,
        retry_attempt: retry_attempt,
        max_slices: max_slices
      )
    end
  rescue StandardError => e
    log "migrate failed, increasing migration_state retry_attempt: #{retry_attempt} error:#{e.message}"

    set_migration_state(
      slice: slice,
      retry_attempt: retry_attempt + 1,
      max_slices: max_slices
    )

    raise e
  end

  def completed?
    log "completed check: Refreshing #{issues_index_name}"
    helper.refresh_index(index_name: issues_index_name)

    original_count = original_issues_documents_count
    new_count = new_issues_documents_count
    log "Checking to see if migration is completed based on index counts: original_count:#{original_count}, new_count:#{new_count}"

    original_count == new_count
  end

  private

  def cleanup
    helper.delete_index(index_name: issues_index_name) if helper.index_exists?(index_name: issues_index_name)
  end

  def reindex(slice:, max_slices:)
    body = query(slice: slice, max_slices: max_slices)

    client.reindex(body: body, wait_for_completion: true)
  end

  def process_response(response)
    if response['failures'].present?
      log_raise "Reindexing failed with #{response['failures']}"
    end

    if response['total'] != (response['updated'] + response['created'] + response['deleted'])
      log_raise "Slice reindexing seems to have failed, total is not equal to updated + created + deleted"
    end
  end

  def query(slice:, max_slices:)
    {
      source: {
        index: default_index_name,
        _source: FIELDS,
        query: {
          match: {
            type: 'issue'
          }
        },
        slice: {
          id: slice,
          max: max_slices
        }
      },
      dest: {
        index: issues_index_name
      }
    }
  end

  def original_issues_documents_count
    query = {
      size: 0,
      aggs: {
        issues: {
          filter: {
            term: {
              type: {
                value: 'issue'
              }
            }
          }
        }
      }
    }

    results = client.search(index: default_index_name, body: query)
    results.dig('aggregations', 'issues', 'doc_count')
  end

  def new_issues_documents_count
    helper.documents_count(index_name: issues_index_name)
  end

  def get_number_of_shards
    helper.get_settings.dig('number_of_shards').to_i
  end

  def default_index_name
    helper.target_name
  end

  def issues_index_name
    "#{default_index_name}-issues"
  end
end
