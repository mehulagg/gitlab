# frozen_string_literal: true

module IncidentManagement
  class CreateIncidentSlaExceededLabelService < BaseService
    LABEL_PROPERTIES = {
      title: 'SLA exceeded',
      color: '#7E6AB0',
      description: <<~DESCRIPTION.chomp
        This incident was not closed before the SLA (Service Level Agreement) time exceeded
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
