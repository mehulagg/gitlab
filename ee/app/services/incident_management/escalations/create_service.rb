# frozen_string_literal: true

module IncidentManagement
  module Escalations
    class CreateService < BaseService
      def initialize(alert, project)
        @alert = alert
        @project = project
      end

      def execute
        return unless ::Gitlab::IncidentManagement.escalation_policies_available?(project) && !alert.resolved?

        policy = project.incident_management_escalation_policies.first

        return unless policy

        create_escalation(policy)
        process_escalation
      end

      private

      def create_escalation(policy)
        @escalation = ::IncidentManagement::AlertEscalation.create!(alert: alert, policy: policy)
      end

      def process_escalation
        ::IncidentManagement::Escalations::ProcessService.new(escalation).execute
      end
    end
  end
end
