# frozen_string_literal: true

class AddNewDataToIssuesDocuments < Elastic::Migration
  batched!
  throttle_delay 5.minutes

  QUERY_BATCH_SIZE = 5000
  UPDATE_BATCH_SIZE = 100

  def migrate
    if completed?
      log "Skipping adding visibility_level field to issues documents migration since it is already applied"
      return
    end

    log "Adding visibility_level field to issues documents for batch of #{QUERY_BATCH_SIZE} documents"

    query = {
      size: QUERY_BATCH_SIZE,
      query: {
        bool: {
          filter: issues_missing_visibility_level_filter
        }
      }
    }

    results = client.search(index: helper.target_index_name, body: query)
    hits = results.dig('hits', 'hits') || []

    document_references = hits.map do |hit|
      id = hit.dig('_source', 'id')
      es_id = hit.dig('_id')
      es_parent = hit.dig('_source', 'join_field', 'parent')

      # ensure that any issues missing from the database will be removed from Elasticsearch
      # as the data is back-filled
      Gitlab::Elastic::DocumentReference.new(Issue, id, es_id, es_parent)
    end

    document_references.each_slice(UPDATE_BATCH_SIZE) do |refs|
      Elastic::ProcessBookkeepingService.track!(*refs)
    end

    log "Adding visibility_level field to issues documents is completed for batch of #{document_references.size} documents"
  end

  def completed?
    query = {
      size: 0,
      aggs: {
        issues: {
          filter: issues_missing_visibility_level_filter
        }
      }
    }

    results = client.search(index: helper.target_index_name, body: query)
    doc_count = results.dig('aggregations', 'issues', 'doc_count')
    doc_count && doc_count == 0
  end

  private

  def issues_missing_visibility_level_filter
    {
      bool: {
        must_not: field_exists('visibility_level'),
        filter: issue_type_filter
      }
    }
  end

  def issue_type_filter
    {
      term: {
        type: {
          value: 'issue'
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
