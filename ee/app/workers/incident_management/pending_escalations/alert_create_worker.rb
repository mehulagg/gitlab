# frozen_string_literal: true

module IncidentManagement
  module PendingEscalations
    class AlertCreateWorker
      include ApplicationWorker

      urgency :high

      idempotent!
      feature_category :incident_management

      def perform(alert_id, service_kwargs = {})
        alert = ::AlertManagement::Alert.find(alert_id)

        ::IncidentManagement::PendingEscalations::CreateService.new(alert, **service_kwargs.symbolize_keys).execute
      end
    end
  end
end
