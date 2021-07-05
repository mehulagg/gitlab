# frozen_string_literal: true

module Analytics
  module DevopsAdoption
    # Schedules update of snapshots for all enabled_namespaces
    class CreateAllSnapshotsWorker
      include ApplicationWorker

      data_consistency :always

      sidekiq_options retry: 3
      # This worker does not perform work scoped to a context
      include CronjobQueue # rubocop:disable Scalability/CronWorkerContext

      feature_category :devops_reports
      tags :exclude_from_kubernetes
      idempotent!

      WORKERS_GAP = 5.seconds

      # rubocop: disable CodeReuse/ActiveRecord
      def perform
        ::Analytics::DevopsAdoption::EnabledNamespace.all.pluck(:id).each.with_index do |enabled_namespace_id, i|
          CreateSnapshotWorker.perform_in(i * WORKERS_GAP, enabled_namespace_id)
        end
      end
      # rubocop: enable CodeReuse/ActiveRecord
    end
  end
end
