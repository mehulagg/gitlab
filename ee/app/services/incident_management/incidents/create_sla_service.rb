# frozen_string_literal: true

module IncidentManagement
  module Incidents
    class CreateSlaService < BaseService
      def initialize(issuable, current_user)
        super(issuable.project, current_user)

        @issuable = issuable
      end

      def execute
        return not_enabled_success unless issuable.sla_available?
        return not_enabled_success unless incident_setting&.sla_timer?
        return success(sla: issuable.issuable_sla) if issuable.issuable_sla

        sla = issuable.build_issuable_sla(
          due_at: issuable.created_at + incident_setting.sla_timer_minutes.minutes
        )

        return success(sla: sla) if sla.save

        error(sla.errors&.full_messages)
      end

      attr_reader :issuable

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
end
