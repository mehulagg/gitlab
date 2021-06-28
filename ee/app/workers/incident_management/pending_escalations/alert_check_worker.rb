# frozen_string_literal: true

module IncidentManagement
  module PendingEscalations
    class AlertCheckWorker
      include ApplicationWorker

      urgency :high

      idempotent!
      feature_category :incident_management

      def initialize(escalation_id)
        @escalation_id = escalation_id
      end

      def perform
        escalation = IncidentManagement::PendingEscalations::Alert.find(escalation_id)

        IncidentManagement::PendingEscalations::ProcessService.new(escalation).execute
      end

      private

      attr_reader :escalation_id
    end
  end
end
