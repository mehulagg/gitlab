# frozen_string_literal: true

class SyncSeatLinkWorker # rubocop:disable Scalability/IdempotentWorker
  include ApplicationWorker
  # rubocop:disable Scalability/CronWorkerContext
  # This worker does not perform work scoped to a context
  include CronjobQueue
  # rubocop:enable Scalability/CronWorkerContext

  feature_category :license

  # Retry for up to approximately 17 hours
  sidekiq_options retry: 12, dead: false

  def perform
    return unless should_sync_seats?

    SyncSeatLinkRequestWorker.perform_async(
      seat_link_data.timestamp.iso8601,
      seat_link_data.key,
      seat_link_data.max_users,
      seat_link_data.active_users
    )
  end

  private

  def seat_link_data
    @seat_link_data ||= Gitlab::SeatLinkData.new
  end

  # Only sync paid licenses from start date until 14 days after expiration
  # when seat link feature is enabled.
  def should_sync_seats?
    Gitlab::CurrentSettings.seat_link_enabled? &&
      License.current &&
      !License.current.trial? &&
      License.current.expires_at && # Skip sync if license has no expiration
      seat_link_data.historical_data_exists? && # Skip sync if there is no historical data
      seat_link_data.timestamp.between?(License.current.starts_at.beginning_of_day, License.current.expires_at.end_of_day + 14.days)
  end
end
