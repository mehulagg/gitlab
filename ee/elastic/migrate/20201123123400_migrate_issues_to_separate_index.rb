# frozen_string_literal: true

class MigrateIssuesToSeparateIndex < Elastic::Migration
  batched!
  throttle_delay 5.seconds

  FIELDS = %w(
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
    # On initial batch we only pause indexing
    if launch_options.blank?
      log "Create standalone issues index under #{issues_index_name}"
      helper.create_standalone_indices unless helper.index_exists?(index_name: issues_index_name)
      log 'Pausing indexing'
      Gitlab::CurrentSettings.update!(elasticsearch_pause_indexing: true)

      options = {
        slice: 0,
        max_slices: helper.get_settings.dig('number_of_shards').to_i
      }
      log "Setting next_launch_options to #{options.inspect}"
      set_next_launch_options(options)

      return
    end

    slice = launch_options[:slice]
    max_slices = launch_options[:max_slices]

    if slice < max_slices
      log "Launching reindexing for slice:#{slice} | max_slices:#{max_slices}"
      body = query(slice: slice, max_slices: max_slices)

      response = client.reindex(body: body, wait_for_completion: true)

      raise "Reindexing failed with #{response['failures']}" if response['failures'].present?

      log "Reindexing for slice:#{slice} | max_slices:#{max_slices} is completed"

      set_next_launch_options(
        slice: slice + 1,
        max_slices: number_of_shards
      )
    end

    if completed?
      log 'Migration is completed. Unpausing indexing'
      Gitlab::CurrentSettings.update!(elasticsearch_pause_indexing: false)
    end
  end

  def completed?
    log "completed check: Refreshing #{issues_index_name}"
    helper.refresh_index(index_name: issues_index_name)

    original_count = original_issues_documents_count
    new_count = new_issues_documents_count
    log "completed check: #{original_count} == #{new_count}"

    original_count == new_count
  end

  private

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

  def number_of_shards
    helper.get_settings.dig('number_of_shards').to_i
  end

  def default_index_name
    helper.target_name
  end

  def issues_index_name
    "#{default_index_name}-issues"
  end
end
