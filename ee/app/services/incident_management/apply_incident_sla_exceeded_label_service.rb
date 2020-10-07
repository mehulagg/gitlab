# frozen_string_literal: true

module IncidentManagement
  class ApplyIncidentSlaExceededLabelService < BaseService
    def initialize(incident)
      super(incident.project)

      @incident = incident
      @label = incident_exceeded_label
    end

    def execute
      return if incident.label_ids.include?(label.id)

      incident.labels << label
    end

    private

    attr_reader :incident, :label

    def incident_exceeded_label
      ::IncidentManagement::CreateIncidentSlaExceededLabelService
        .new(project, current_user)
        .execute
        .payload[:label]
    end
  end
end
