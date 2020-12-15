# frozen_string_literal: true

module IncidentManagement
  class PersistAllOncallShiftsJob
    include ApplicationWorker

    idempotent!
    feature_category :incident_management
    queue_namespace :cronjob

    def perform
      # TODO, only loop around currently active rotations?
      IncidentManagement::OncallRotation.all.pluck(:id).each do |rotation_id| # rubocop: disable CodeReuse/ActiveRecord
        IncidentManagement::OncallRotations::PersistOncallShiftsJob.perform_async(rotation_id)
      end
    end
  end
end
