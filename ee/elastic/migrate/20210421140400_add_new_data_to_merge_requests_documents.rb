# frozen_string_literal: true

class AddNewDataToMergeRequestsDocuments < Elastic::Migration
  batched!
  throttle_delay 3.minutes

  QUERY_BATCH_SIZE = 6000
  UPDATE_BATCH_SIZE = 100

  def migrate
    if completed?
      log "Skipping adding visibility_level field to merge_requests documents migration since it is already applied"
      return
    end

    log "Adding visibility_level field to merge_requests documents for batch of #{QUERY_BATCH_SIZE} documents"

    query = {
      size: QUERY_BATCH_SIZE,
      query: {
        bool: {
          filter: merge_requests_missing_visibility_level_filter
        }
      }
    }

    results = client.search(index: helper.target_index_name, body: query)
    hits = results.dig('hits', 'hits') || []

    document_references = hits.map do |hit|
      id = hit.dig('_source', 'id')
      es_id = hit.dig('_id')
      es_parent = hit.dig('_source', 'join_field', 'parent')

      # ensure that any merge_requests missing from the database will be removed from Elasticsearch
      # as the data is back-filled
      Gitlab::Elastic::DocumentReference.new(MergeRequest, id, es_id, es_parent)
    end

    document_references.each_slice(UPDATE_BATCH_SIZE) do |refs|
      Elastic::ProcessInitialBookkeepingService.track!(*refs)
    end

    log "Adding visibility_level field to merge_requests documents is completed for batch of #{document_references.size} documents"
  end

  def completed?
    log "completed check: Refreshing #{helper.target_index_name}"
    helper.refresh_index(index_name: helper.target_index_name)

    query = {
      size: 0,
      aggs: {
        merge_requests: {
          filter: merge_requests_missing_visibility_level_filter
        }
      }
    }

    results = client.search(index: helper.target_index_name, body: query)
    doc_count = results.dig('aggregations', 'merge_requests', 'doc_count')
    log "Migration has #{doc_count} documents remaining" if doc_count
    doc_count && doc_count == 0
  end

  private

  def merge_requests_missing_visibility_level_filter
    {
      bool: {
        must_not: field_exists('visibility_level'),
        filter: merge_request_type_filter
      }
    }
  end

  def merge_request_type_filter
    {
      term: {
        type: {
          value: 'merge_request'
        }
      }
    }
  end

  def field_exists(field)
    {
      exists: {
        field: field
      }
    }
  end
end
