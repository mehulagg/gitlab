# frozen_string_literal: true

module EE
  module Projects
    module AlertManagementHelper
      extend ::Gitlab::Utils::Override

      override :alert_management_data
      def alert_management_data(current_user, project)
        super.merge(
          alert_management_opsgenie_mvc_data(project.alerts_service)
        )
      end

      private

      def alert_management_opsgenie_mvc_data(alerts_service)
        return {} unless alerts_service&.opsgenie_mvc_available?

        {
          'opsgenie_mvc_available' => 'true',
          'opsgenie_mvc_enabled' => alerts_service.opsgenie_mvc_enabled?.to_s,
          'opsgenie_mvc_target_url' => alerts_service.opsgenie_mvc_target_url.to_s
        }
      end
    end
  end
end
