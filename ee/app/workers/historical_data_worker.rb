# frozen_string_literal: true

class HistoricalDataWorker # rubocop:disable Scalability/IdempotentWorker
  include ApplicationWorker
  # rubocop:disable Scalability/CronWorkerContext
  # This worker does not perform work scoped to a context
  include CronjobQueue
  # rubocop:enable Scalability/CronWorkerContext

  feature_category :provision

  def perform
    return if License.current.nil? || License.current.trial?

    HistoricalData.track!
  end
end
