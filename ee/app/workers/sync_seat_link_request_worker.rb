# frozen_string_literal: true

class SyncSeatLinkRequestWorker
  include ApplicationWorker

  feature_category :billing

  idempotent!
  worker_has_external_dependencies!

  URI_PATH = '/api/v1/seat_links'

  RequestError = Class.new(StandardError)

  def perform(date, license_key, max_historical_user_count, active_users)
    response = Gitlab::HTTP.post(
      URI_PATH,
      base_uri: EE::SUBSCRIPTIONS_URL,
      headers: request_headers,
      body: request_body(date, license_key, max_historical_user_count, active_users)
    )

    raise RequestError, request_error_message(response) unless response.success?
  end

  private

  def request_body(date, license_key, max_historical_user_count, active_users)
    Gitlab::SeatLinkData.new(
      date: date,
      key: license_key,
      max_users: max_historical_user_count,
      active_users: active_users
    ).to_json
  end

  def request_headers
    { 'Content-Type' => 'application/json' }
  end

  def request_error_message(response)
    "Seat Link request failed! Code:#{response.code} Body:#{response.body}"
  end
end
