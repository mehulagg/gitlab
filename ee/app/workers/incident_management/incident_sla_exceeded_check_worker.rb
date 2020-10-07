# frozen_string_literal: true

module IncidentManagement
  class IncidentSlaExceededCheckWorker
    include ApplicationWorker
    include CronjobQueue # rubocop:disable Scalability/CronWorkerContext

    feature_category :incident_management

    def perform
      IncidentSla.exceeded.find_in_batches do |incident_slas|
        incident_slas.each do |incident_sla|
          ApplyIncidentSlaExceededLabelService.new(incident_sla.issue).execute
        end
      end
    end
  end
end
