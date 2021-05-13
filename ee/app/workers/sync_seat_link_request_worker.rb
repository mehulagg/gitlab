# frozen_string_literal: true

class SyncSeatLinkRequestWorker
  include ApplicationWorker

  feature_category :license

  # Retry for up to approximately 6 days
  sidekiq_options retry: 20

  idempotent!
  worker_has_external_dependencies!

  URI_PATH = '/api/v1/seat_links'

  RequestError = Class.new(StandardError)

  def perform(timestamp, license_key, max_historical_user_count, active_users)
    response = Gitlab::HTTP.post(
      URI_PATH,
      base_uri: EE::SUBSCRIPTIONS_URL,
      headers: request_headers,
      body: request_body(timestamp, license_key, max_historical_user_count, active_users)
    )

    if response.success?
      reset_license!(response['license']) if response['license']
    else
      raise RequestError, request_error_message(response)
    end
  end

  private

  def reset_license!(license_data)
    current_license = License.current if License.current&.cloud_license?

    License.transaction do
      current_license&.destroy!
      License.create!(data: license_data, cloud: true)
    end
  rescue StandardError => e
    Gitlab::ErrorTracking.track_and_raise_for_dev_exception(e)
  end

  def request_body(timestamp, license_key, max_historical_user_count, active_users)
    Gitlab::SeatLinkData.new(
      timestamp: Time.zone.parse(timestamp),
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
