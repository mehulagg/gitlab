# frozen_string_literal: true

class AddPermissionsDataToNotesDocuments < Elastic::Migration
  batched!
  throttle_delay 3.minutes

  QUERY_BATCH_SIZE = 6_000
  UPDATE_BATCH_SIZE = 100

  def migrate
    if completed?
      log "Skipping adding permission data to notes documents migration since it is already applied"
      return
    end

    log "Adding permission data to notes documents for batch of #{QUERY_BATCH_SIZE} documents"

    query = es_query.merge(size: QUERY_BATCH_SIZE)
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
      Elastic::ProcessInitialBookkeepingService.track!(*refs)
    end

    log "Adding permission data to notes documents is completed for batch of #{document_references.size} documents"
  end

  def completed?
    log "completed check: Refreshing #{helper.target_index_name}"
    helper.refresh_index(index_name: helper.target_index_name)

    results = client.count(index: helper.target_index_name, body: es_query)
    doc_count = results.dig('count')
    log "Migration has #{doc_count} documents remaining" if doc_count

    doc_count && doc_count == 0
  end

  private

  def es_query
    {
      query: {
        bool: {
          filter: {
            bool: {
              must: note_type_filter,
              should: [
                field_does_not_exist_for_type('visibility_level', 'Issue'),
                field_does_not_exist_for_type('visibility_level', 'Commit'),
                field_does_not_exist_for_type('visibility_level', 'MergeRequest'),
                field_does_not_exist_for_type('visibility_level', 'Snippet'),
                field_does_not_exist_for_type('issues_access_level', 'Issue'),
                field_does_not_exist_for_type('repository_access_level', 'Commit'),
                field_does_not_exist_for_type('merge_requests_access_level', 'MergeRequest'),
                field_does_not_exist_for_type('snippets_access_level', 'Snippet')
              ],
              minimum_should_match: 1
            }
          }
        }
      }
    }
  end

  def note_type_filter
    {
      term: {
        type: {
          value: 'note'
        }
      }
    }
  end

  def field_does_not_exist_for_type(field, type)
    {
      bool: {
        must: {
          term: {
            noteable_type: {
              value: type
            }
          }
        },
        must_not: {
          exists: {
            field: field
          }
        }
      }
    }
  end
end
