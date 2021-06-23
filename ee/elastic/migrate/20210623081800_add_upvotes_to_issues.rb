# frozen_string_literal: true

class AddUpvotesToIssues < Elastic::Migration
  DOCUMENT_TYPE = Issue

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

    true
  end

  def completed?
    query = {
      size: 0,
      aggs: {
        issues: {
          filter: {
            bool: {
              must_not: {
                exists: {
                  field: 'upvotes'
                }
              }
            }
          }
        }
      }
    }

    results = client.search(index: index_name, body: query)
    doc_count = results.dig('aggregations', 'issues', 'doc_count')
    doc_count && doc_count == 0
  end

  private

  def index_name
    helper.standalone_indices_proxies(target_classes: [DOCUMENT_TYPE]).map(&:index_name).first
  end
end
