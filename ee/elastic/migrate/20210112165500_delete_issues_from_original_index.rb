# frozen_string_literal: true

class DeleteIssuesFromOriginalIndex < Elastic::Migration
  batched!
  throttle_delay 1.minute

  QUERY_BODY = {
                 query: {
                   term: {
                     type: 'issue'
                   }
                 }
               }.freeze

  def migrate
    if completed?
      log "Skipping removing issues from the original index since it is already applied"
      return
    end

    response = client.delete_by_query(index: helper.target_name, body: QUERY_BODY)

    raise "Failed to delete issues: #{response['failures']}" if response['failures'].present?
  end

  def completed?
    results = client.search(index: helper.target_name, body: QUERY_BODY.merge(size: 0))
    results.dig('hits', 'total', 'value') == 0
  end

  private

  def query
  end
end
