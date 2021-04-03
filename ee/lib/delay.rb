# frozen_string_literal: true

module Delay
  # Progressive backoff. It's copied from Sidekiq as is
  def delay(retry_count = 0)
    (retry_count**4) + 15 + (rand(30) * (retry_count + 1))
  end

  # To prevent the retry time from storing invalid dates in the database,
  # cap the max time to a hour plus some random jitter value.
  def next_retry_time(retry_count, custom_max_wait_time = nil)
    proposed_time = Time.now + delay(retry_count).seconds
    max_wait_time = custom_max_wait_time || 1.hour
    max_future_time = max_wait_time.from_now + delay(1).seconds

    [proposed_time, max_future_time].min
  end
end
