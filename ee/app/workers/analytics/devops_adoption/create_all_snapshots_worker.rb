# frozen_string_literal: true

module Analytics
  module DevopsAdoption
    class CreateAllSnapshotsWorker
      include ApplicationWorker
      # This worker does not perform work scoped to a context
      include CronjobQueue # rubocop:disable Scalability/CronWorkerContext

      feature_category :devops_reports
      idempotent!

      WORKERS_GAP = 5.seconds

      # rubocop: disable CodeReuse/ActiveRecord
      def perform
        range_end = Time.zone.now
        ::Analytics::DevopsAdoption::Segment.all.pluck(:id).each.with_index do |segment_id, i|
          CreateSnapshotWorker.perform_in(i * WORKERS_GAP, segment_id, range_end)
        end
      end
      # rubocop: enable CodeReuse/ActiveRecord
    end
  end
end
