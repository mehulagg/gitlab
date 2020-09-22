# frozen_string_literal: true

module Analytics
  module InstanceStatistics
    class CountJobTriggerWorker
      include ApplicationWorker
      include CronjobQueue # rubocop:disable Scalability/CronWorkerContext

      DEFAULT_DELAY = 3.minutes.freeze

      feature_category :instance_statistics
      urgency :low

      idempotent!

      def perform
        return if Feature.disabled?(:store_instance_statistics_measurements, default_enabled: true)

        recorded_at = Time.zone.now

        worker_arguments = Gitlab::Analytics::InstanceStatistics::WorkersArgumentBuilder.new(
          measurement_identifiers: measurement_identifier_values,
          recorded_at: recorded_at
        ).execute

        perform_in = DEFAULT_DELAY.minutes.from_now
        worker_arguments.each do |args|
          CounterJobWorker.perform_in(perform_in, *args)

          perform_in += DEFAULT_DELAY
        end
      end

      private

      def measurement_identifier_values
        identifiers = Analytics::InstanceStatistics::Measurement.identifiers

        if Feature.enabled?(:store_ci_pipeline_counts_by_status)
          identifiers.values
        else
          keys = Analytics::InstanceStatistics::Measurement::CI_PIPELINE_STATUS_MAPPING.keys
          identifiers.except(*keys).values
        end
      end
    end
  end
end
