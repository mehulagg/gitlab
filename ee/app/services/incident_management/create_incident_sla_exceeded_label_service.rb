# frozen_string_literal: true

module IncidentManagement
  class CreateIncidentSlaExceededLabelService < BaseService
    def self.doc_url
      Rails.application.routes.url_helpers.help_page_url('operations/incident_management/incidents', anchor: 'service-level-agreement-countdown-timer')
    end

    LABEL_PROPERTIES = {
      title: 'missed::SLA',
      color: '#D9534F',
      description: <<~DESCRIPTION.chomp
        Incidents that have missed the targeted SLA (Service Level Agreement). #{doc_url}
      DESCRIPTION
    }.freeze

    def execute
      label = Labels::FindOrCreateService
        .new(current_user, project, **LABEL_PROPERTIES)
        .execute(skip_authorization: true)

      ServiceResponse.success(payload: { label: label })
    end
  end
end
