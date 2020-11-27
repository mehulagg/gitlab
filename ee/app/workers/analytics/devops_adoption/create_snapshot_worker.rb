# frozen_string_literal: true

module Analytics
  module DevopsAdoption
    class CreateSnapshotWorker
      include ApplicationWorker

      feature_category :devops_adoption_analytics
      idempotent!

      def perform(segment_id)
        segment = ::Analytics::DevopsAdoption::Segment.find(segment_id)

        ::Analytics::DevopsAdoption::Snapshots::CalculateAndSaveService.new(segment: segment).execute
      end
    end
  end
end
