# frozen_string_literal: true

class AddNewDataToIssuesDocuments < Elastic::Migration
  batch_update!

  def migrate
    if completed?
      log "Skipping adding issues_access_level fields to issues documents migration since it is already applied"
      return
    end

    log "Adding issues_access_level fields to issues documents"

    # get a batch of issues missing data
    query = {
      size: 1000,
      query: {
        bool: {
          must: {
            match_all: {}
          },
          filter: {
            bool: {
              should: [
                must_not_have_field('issues_access_level')
              ],
              minimum_should_match: 1,
              filter: issue_type_filter
            }
          }
        }
      }
    }

    # work through them in batches
    loop do
      results = client.search(index: helper.target_index_name, body: query)
      hits = results.dig('hits', 'hits')
      break if hits.empty?

      hits.each do |hit|
        id = hit.dig('_source', 'id')
        es_id = hit.dig('_id')
        es_parent = hit.dig('_source', 'join_field', 'parent')

        # ensure that any issues missing from the database will be removed from Elasticsearch
        # as the data is back-filled
        issue_document_reference = Gitlab::Elastic::DocumentReference.new(Issue.class.name, id, es_id, es_parent)
        Elastic::ProcessBookkeepingService.track!(issue_document_reference)
      end
    end

    # kick off indexing for each individually
    # do we need to wait or how do we tell that it's done?

    log 'Adding issues_access_level fields to issues documents is completed'
  end

  def completed?
    # TODO - there are orphaned issues in the index
    # that will not allow us to use this for the completed?
    # need to figure out what is going to allow us to know this is done
    # could create a whole new queue (like in ProcessBookkeepingService)
    # but not using that queue would mean we lose deduplication benefit
    # We could check all of the issues missing data and check if any of them exist in the database, if
    # any do exist, then we know this is not completed. How much paging/size to use here is a question

    # can use the idea below if we don't use the database to find the issue, construct the document reference correctly

    # query counts all issue documents that are missing the
    # field issues_access_level
    query = {
      query: {
        match_all: {}
      },
      size: 0,
      aggs: {
        issues: {
          filter: {
            bool: {
              should: [
                must_not_have_field('issues_access_level')
              ],
              minimum_should_match: 1,
              filter: issue_type_filter
            }
          }
        }
      }
    }

    results = client.search(index: helper.target_index_name, body: query)
    doc_count = results.dig('aggregations', 'issues', 'doc_count')
    doc_count && doc_count > 0
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

  def must_not_have_field(field)
    {
      bool: {
        must_not: [
          {
            exists: {
              field: field
            }
          }
        ]
      }
    }
  end
end
