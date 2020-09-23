# frozen_string_literal: true

class SyncSeatLinkWorker # rubocop:disable Scalability/IdempotentWorker
  include ApplicationWorker
  # rubocop:disable Scalability/CronWorkerContext
  # This worker does not perform work scoped to a context
  include CronjobQueue
  # rubocop:enable Scalability/CronWorkerContext

  feature_category :billing

  # Retry for up to approximately 17 hours
  sidekiq_options retry: 12, dead: false

  def perform
    return unless should_sync_seats?

    SyncSeatLinkRequestWorker.perform_async(
      seat_link_data.date.to_s,
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
      seat_link_data.date.between?(License.current.starts_at, License.current.expires_at + 14.days)
  end
end
