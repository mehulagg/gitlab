# frozen_string_literal: true

module IncidentManagement
  class CreateIncidentSlaExceededLabelService < BaseService
    def execute
      label = Labels::FindOrCreateService
        .new(current_user, project, **label_properties)
        .execute(skip_authorization: true)

      ServiceResponse.success(payload: { label: label })
    end

    private

    def label_properties
      @label_properties ||= {
        title: 'missed::SLA',
        color: '#D9534F',
        description: <<~DESCRIPTION.chomp
          Incidents that have missed the targeted SLA (Service Level Agreement). #{doc_url}
        DESCRIPTION
      }.freeze
    end

    def doc_url
      Rails.application.routes.url_helpers.help_page_url('operations/incident_management/incidents', anchor: 'service-level-agreement-countdown-timer')
    end
  end
end
