# frozen_string_literal: true

class DeleteNotesFromOriginalIndex < Elastic::Migration
  batched!
  throttle_delay 3.minutes

  MAX_ATTEMPTS = 30

  QUERY_BODY = {
    query: {
      term: {
        type: 'note'
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
      log "Skipping removing notes from the original index since it is already applied"
      return
    end

    response = client.delete_by_query(index: helper.target_name, body: QUERY_BODY)

    log_raise "Failed to delete notes: #{response['failures']}" if response['failures'].present?
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
    total_remaining = results.dig('hits', 'total', 'value')
    log "Checking to see if migration is completed based on index counts remaining:#{total_remaining}"

    total_remaining == 0
  end
end
