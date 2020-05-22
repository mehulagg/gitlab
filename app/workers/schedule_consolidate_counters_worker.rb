# frozen_string_literal: true

# Run as cronjob and schedule a worker for each model using
# CounterAttribute concern.
#
# TODO: This worker is currently not added to config/initializers/1_settings.rb
#   until we start using CounterAttribute concern.
class ScheduleConsolidateCountersWorker
  include ApplicationWorker
  # rubocop:disable Scalability/CronWorkerContext
  # This worker does not perform work scoped to a context.
  # It schedules consolidation processs for each model
  # using counter attributes.
  include CronjobQueue
  # rubocop:enable Scalability/CronWorkerContext
  include Gitlab::ExclusiveLeaseHelpers

  feature_category_not_owned!
  idempotent!

  COUNTER_ATTRIBUTE_MODELS = [
    # Insert here new models using `include CounterAttribute`
  ].freeze

  def perform
    COUNTER_ATTRIBUTE_MODELS.each do |model|
      ConsolidateCountersWorker.perform_async(model.name)
    end
  end
end
