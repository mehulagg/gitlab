# frozen_string_literal: true

class ConsolidateCountersWorker
  include ApplicationWorker
  include Gitlab::ExclusiveLeaseHelpers

  feature_category_not_owned!
  idempotent!

  LOCK_TTL = 10.minutes

  def perform(model_class)
    return unless self.class.const_defined?(model_class)

    model = model_class.constantize

    lock_key = "counter-attributes:#{model_class}"

    in_lock(lock_key, ttl: LOCK_TTL) do
      model.slow_consolidate_counter_attributes!
    end
  rescue Gitlab::ExclusiveLeaseHelpers::FailedToObtainLockError
    # a worker is already updating the counters
  end
end
