# frozen_string_literal: true

module EE
  module AlertManagement
    module Alerts
      module UpdateService
        extend ::Gitlab::Utils::Override

        override :handle_status_change
        def handle_status_change(old_status)
          super

          destroy_open_escalations if resolved?

          if !::AlertManagement::Alert.open_status?(old_status) && open?
            create_escalation
          end
        end

        private

        def destroy_open_escalations
          IncidentManagement::AlertEscalation.for_alert(alert).delete_all
        end

        def create_escalation
          ::IncidentManagement::Escalations::CreateService.new(alert).execute
        end
      end
    end
  end
end
