# frozen_string_literal: true

class AddUpvotesToIssues < Elastic::Migration
  batched!
  throttle_delay 3.minutes

  DOCUMENT_TYPE = Issue
  QUERY_BATCH_SIZE = 5000
  UPDATE_BATCH_SIZE = 100

  def migrate
    client.indices.put_mapping index: index_name, body: {
      properties: {
        upvotes: { type: 'integer' }
      }
    }

    if completed?
      log "Skipping adding upvotes field to issues documents migration since it is already applied"
      return
    end

    log "Adding upvotes field to issues documents for batch of #{QUERY_BATCH_SIZE} documents"

    query = {
      size: QUERY_BATCH_SIZE,
      query: {
        bool: {
          filter: issues_missing_upvotes_field
        }
      }
    }

    results = client.search(index: index_name, body: query)
    hits = results.dig('hits', 'hits') || []

    document_references = hits.map do |hit|
      id = hit.dig('_source', 'id')
      es_id = hit.dig('_id')
      es_parent = "project_#{hit.dig('_source', 'project_id')}"

      # ensure that any issues missing from the database will be removed from Elasticsearch
      # as the data is back-filled
      Gitlab::Elastic::DocumentReference.new(Issue, id, es_id, es_parent)
    end

    document_references.each_slice(UPDATE_BATCH_SIZE) do |refs|
      Elastic::ProcessInitialBookkeepingService.track!(*refs)
    end

    log "Adding upvotes field to issues documents is completed for batch of #{document_references.size} documents"
  end

  def completed?
    query = {
      size: 0,
      aggs: {
        issues: {
          filter: issues_missing_upvotes_field
        }
      }
    }

    results = client.search(index: index_name, body: query)
    doc_count = results.dig('aggregations', 'issues', 'doc_count')
    doc_count && doc_count == 0
  end

  private

  def issues_missing_upvotes_field
    {
      bool: {
        must_not: {
          exists: {
            field: 'upvotes'
          }
        }
      }
    }
  end

  def index_name
    DOCUMENT_TYPE.__elasticsearch__.index_name
  end
end
