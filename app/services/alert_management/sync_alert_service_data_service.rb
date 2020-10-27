# frozen_string_literal: true

module AlertManagement
  class SyncAlertServiceDataService

    # @param alert_service [AlertsService]
    def initialize(alert_service)
      @alert_service = alert_service
    end

    def execute
      http_integration = find_http_integration

      return ServiceResponse.success(message: 'HTTP Integration not found') unless http_integration

      result = update_integration_data(http_integration)
      result ? ServiceResponse.success : ServiceResponse.error(message: 'Update failed')
    end

    private

    attr_reader :alert_service

    def find_http_integration
      AlertManagement::HttpIntegrationsFinder.new(
          alert_service.project,
          endpoint_identifier: ::AlertManagement::HttpIntegration::LEGACY_IDENTIFIER
        )
      .execute
      .first
    end

    def update_integration_data(http_integration)
      http_integration.update!(
        active: alert_service.active,
        encrypted_token: alert_service.data.encrypted_token,
        encrypted_token_iv: alert_service.data.encrypted_token_iv
      )
    end
  end
end
