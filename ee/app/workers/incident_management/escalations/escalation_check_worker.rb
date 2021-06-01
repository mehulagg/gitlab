# frozen_string_literal: true

module IncidentManagement
  module Escalations
    class EscalationCheckWorker
      include ApplicationWorker

      urgency :high

      idempotent!
      feature_category :incident_management
      tags :exclude_from_kubernetes

      def initialize(escalation_class, escalation_id)
        @escalation_class = escalation_class
        @escalation_id = escalation_id
      end

      def perform
        escalation = escalation_class.constantize.find_by_id(escalation_id)

        return unless escalation

        IncidentManagement::Escalations::ProcessService.new(escalation).execute
      end

      private

      attr_reader :escalation_class, :escalation_id
    end
  end
end
