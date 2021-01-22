# frozen_string_literal: true

module Analytics
  module DevopsAdoption
    # Updates all pending snapshots for given segment (from previous month)
    # and creates or update snapshot for current month
    class CreateSnapshotWorker
      include ApplicationWorker

      feature_category :devops_reports
      idempotent!

      # range_end was deprecated and must be removed in 14.0
      #
      def perform(segment_id, _deprecated_range_end = nil)
        segment = Segment.find(segment_id)

        pending_ranges(segment).each do |range_end|
          Snapshots::CalculateAndSaveService.new(segment: segment, range_end: range_end).execute
        end
      end

      private

      # rubocop: disable CodeReuse/ActiveRecord
      def pending_ranges(segment)
        end_times = segment.snapshots.not_finalized.pluck(:end_time)

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
