# frozen_string_literal: true

module IncidentManagement
  class CreateSlaService < BaseService
    def initialize(incident, current_user)
      super(incident.project, current_user)

      @incident = incident
    end

    def execute
      return not_enabled_success unless incident.sla_available?
      return not_enabled_success unless incident_setting&.sla_timer?

      sla = incident.build_incident_sla(
        due_at: incident.created_at + incident_setting.sla_timer_minutes.minutes
      )

      return success(sla: sla) if sla.save

      error(sla.errors&.full_messages)
    end

    attr_reader :incident

    private

    def not_enabled_success
      ServiceResponse.success(message: 'SLA not enabled')
    end

    def success(payload)
      ServiceResponse.success(payload: payload)
    end

    def error(message)
      ServiceResponse.error(message: message)
    end

    def incident_setting
      @incident_setting ||= project.incident_management_setting
    end
  end
end
