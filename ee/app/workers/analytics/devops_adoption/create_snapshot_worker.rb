# frozen_string_literal: true

module Analytics
  module DevopsAdoption
    class CreateSnapshotWorker
      include ApplicationWorker

      feature_category :devops_reports
      idempotent!

      def perform(segment_id, range_end)
        segment = ::Analytics::DevopsAdoption::Segment.find(segment_id)

        ::Analytics::DevopsAdoption::Snapshots::CalculateAndSaveService.new(segment: segment, range_end: range_end).execute
      end
    end
  end
end
