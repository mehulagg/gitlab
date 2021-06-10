# frozen_string_literal: true

module Analytics
  module DevopsAdoption
    # Updates all pending snapshots for given enabled_namespace (from previous month)
    # and creates or update snapshot for current month
    class CreateSnapshotWorker
      include ApplicationWorker

      sidekiq_options retry: 3

      feature_category :devops_reports
      idempotent!
      tags :exclude_from_kubernetes

      def perform(enabled_namespace_id)
        enabled_namespace = EnabledNamespace.find(enabled_namespace_id)

        pending_ranges(enabled_namespace).each do |range_end|
          Snapshots::CalculateAndSaveService.new(enabled_namespace: enabled_namespace, range_end: range_end).execute
        end
      end

      private

      # rubocop: disable CodeReuse/ActiveRecord
      def pending_ranges(enabled_namespace)
        end_times = enabled_namespace.snapshots.not_finalized.pluck(:end_time)

        now = Time.zone.now

        if !now.end_of_month.to_date.in?(end_times.map(&:to_date)) && now.day > 1
          end_times << now.end_of_month
        end

        end_times
      end
      # rubocop: enable CodeReuse/ActiveRecord
    end
  end
end
