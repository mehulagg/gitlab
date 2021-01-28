# frozen_string_literal: true

class DeleteIssuesFromOriginalIndex < Elastic::Migration
  batched!
  throttle_delay 1.minute

  MAX_ATTEMPTS = 30

  QUERY_BODY = {
                 query: {
                   term: {
                     type: 'issue'
                   }
                 }
               }.freeze

  def migrate
    retry_attempt = migration_state[:retry_attempt].to_i

    if retry_attempt >= MAX_ATTEMPTS
      fail_migration_halt_error!(retry_attempt: retry_attempt)
      return
    end

    if completed?
      log "Skipping removing issues from the original index since it is already applied"
      return
    end

    response = client.delete_by_query(index: helper.target_name, body: QUERY_BODY)

    log_raise "Failed to delete issues: #{response['failures']}" if response['failures'].present?
  rescue StandardError => e
    log "migrate failed, increasing migration_state retry_attempt: #{retry_attempt} error:#{e.class}:#{e.message}"

    set_migration_state(
      retry_attempt: retry_attempt + 1
    )

    raise e
  end

  def completed?
    helper.refresh_index

    results = client.search(index: helper.target_name, body: QUERY_BODY.merge(size: 0))
    results.dig('hits', 'total', 'value') == 0
  end
end
