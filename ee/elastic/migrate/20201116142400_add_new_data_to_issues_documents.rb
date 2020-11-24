# frozen_string_literal: true

class AddNewDataToIssuesDocuments < Elastic::Migration
  migration_options batched: true, throttle_delay: 5.minutes

  BATCH_SIZE = 5000

  def migrate
    if completed?
      log "Skipping adding issues_access_level fields to issues documents migration since it is already applied"
      return false
    end

    log "Adding issues_access_level fields to issues documents for batch of #{BATCH_SIZE} documents"

    # get a batch of issues missing data
    query = {
      size: BATCH_SIZE,
      query: {
        bool: {
          must: {
            match_all: {}
          },
          filter: {
            bool: {
              must_not: field_exists('issues_access_level'),
              filter: issue_type_filter
            }
          }
        }
      }
    }

    # work a batch of issues
    results = client.search(index: helper.target_index_name, body: query)
    hits = results.dig('hits', 'hits') || []

    hits.each do |hit|
      id = hit.dig('_source', 'id')
      es_id = hit.dig('_id')
      es_parent = hit.dig('_source', 'join_field', 'parent')

      # ensure that any issues missing from the database will be removed from Elasticsearch
      # as the data is back-filled
      issue_document_reference = Gitlab::Elastic::DocumentReference.new(Issue.class.name, id, es_id, es_parent)
      Elastic::ProcessBookkeepingService.track!(issue_document_reference)
    end

    log "Adding issues_access_level fields to issues documents is completed for batch of #{BATCH_SIZE} documents"
    true
  end

  def completed?
    query = {
      query: {
        match_all: {}
      },
      size: 0,
      aggs: {
        issues: {
          filter: {
            bool: {
              must_not: field_exists('issues_access_level'),
              filter: issue_type_filter
            }
          }
        }
      }
    }

    results = client.search(index: helper.target_index_name, body: query)
    doc_count = results.dig('aggregations', 'issues', 'doc_count')
    doc_count && doc_count == 0
  end

  private

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
