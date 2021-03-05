# frozen_string_literal: true

module IncidentManagement
  module OncallRotations
    class PersistAllRotationsShiftsJob
      include ApplicationWorker

      idempotent!
      feature_category :incident_management
      queue_namespace :cronjob

      def perform
        @time = Time.current

        # Use two queries to improve performance & better utilize index.
        queue_jobs_for_started_rotations_with_end_time
        queue_jobs_for_started_rotations_without_end_time
      end

      private

      def queue_jobs_for_started_rotations_with_end_time
        IncidentManagement::OncallRotation
          .started(@time)
          .unended(@time)
          .each_batch { |rotations| queue_persist_jobs_for_ids(rotations.ids) }
      end

      def queue_jobs_for_started_rotations_without_end_time
        IncidentManagement::OncallRotation
          .started(@time)
          .unending
          .each_batch { |rotations| queue_persist_jobs_for_ids(rotations.ids) }
      end

      def queue_persist_jobs_for_ids(rotation_ids)
        rotation_ids.each do |id|
          IncidentManagement::OncallRotations::PersistShiftsJob.perform_async(id)
        end
      end
    end
  end
end
