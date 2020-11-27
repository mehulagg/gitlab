# frozen_string_literal: true

module Analytics
  module DevopsAdoption
    class CreateAllSnapshotsWorker
      include ApplicationWorker

      feature_category :devops_adoption_analytics
      idempotent!

      # rubocop: disable CodeReuse/ActiveRecord
      def perform
        ::Analytics::DevopsAdoption::Segment.all.pluck(:id).each do |segment_id|
          CreateSnapshotWorker.perform_async(segment_id)
        end
      end
      # rubocop: enable CodeReuse/ActiveRecord
    end
  end
end
