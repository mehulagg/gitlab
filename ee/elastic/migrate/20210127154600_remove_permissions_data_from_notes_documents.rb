# frozen_string_literal: true

class RemovePermissionsDataFromNotesDocuments < Elastic::Migration
  batched!
  throttle_delay 1.minute

  QUERY_BATCH_SIZE = 5000
  UPDATE_BATCH_SIZE = 100

  def migrate
    log "Removing permission data from notes migration starting"

    if completed?
      log "Skipping removing permission data from notes documents migration since it is already applied"
      return
    end

    log "Removing permission data from notes documents for batch of #{QUERY_BATCH_SIZE} documents"

    # use filter query to prevent scores from being calculated
    query = {
      size: QUERY_BATCH_SIZE,
      query: {
        bool: {
          filter: {
            bool: {
              must: note_type_filter,
              should: [
                field_exists('visibility_level'),
                field_exists_for_type('issues_access_level', 'Issue'),
                field_exists_for_type('repository_access_level', 'Commit'),
                field_exists_for_type('merge_requests_access_level', 'MergeRequest'),
                field_exists_for_type('snippets_access_level', 'Snippet')
              ],
              minimum_should_match: 1
            }
          }
        }
      }
    }

    results = client.search(index: helper.target_index_name, body: query)
    hits = results.dig('hits', 'hits') || []

    document_references = hits.map do |hit|
      id = hit.dig('_source', 'id')
      es_id = hit.dig('_id')
      es_parent = hit.dig('_source', 'join_field', 'parent')

      # ensure that any notes missing from the database will be removed from Elasticsearch
      # as the data is back-filled
      Gitlab::Elastic::DocumentReference.new(Note, id, es_id, es_parent)
    end

    document_references.each_slice(UPDATE_BATCH_SIZE) do |refs|
      Elastic::ProcessBookkeepingService.track!(*refs)
    end

    log "Removing permission data from notes documents is completed for batch of #{document_references.size} documents"
  end

  def completed?
    log "completed check: Refreshing #{helper.target_index_name}"
    helper.refresh_index(index_name: helper.target_index_name)

    query = {
      size: 0,
      query: note_type_filter,
      aggs: {
        notes: {
          filter: {
            bool: {
              should: [
                field_exists('visibility_level'),
                field_exists_for_type('issues_access_level', 'Issue'),
                field_exists_for_type('repository_access_level', 'Commit'),
                field_exists_for_type('merge_requests_access_level', 'MergeRequest'),
                field_exists_for_type('snippets_access_level', 'Snippet')
              ],
              minimum_should_match: 1
            }
          }
        }
      }
    }

    results = client.search(index: helper.target_index_name, body: query)
    doc_count = results.dig('aggregations', 'notes', 'doc_count')
    log "Migration has #{doc_count} documents remaining" if doc_count

    doc_count && doc_count == 0
  end

  private

  def note_type_filter
    {
      term: {
        type: {
          value: 'note'
        }
      }
    }
  end

  def field_exists(field)
    {
      bool: {
        must: [
          {
            exists: {
              field: field
            }
          }
        ]
      }
    }
  end

  def field_exists_for_type(field, type)
    query = field_exists(field)
    query[:bool][:must] << {
      term: {
        noteable_type: {
          value: type
        }
      }
    }
    query
  end
end
