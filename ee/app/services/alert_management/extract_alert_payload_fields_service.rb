# frozen_string_literal: true

module AlertManagement
  class ExtractAlertPayloadFieldsService < BaseContainerService
    alias_method :project, :container

    def execute
      return error(_('Feature not available')) unless available?

      success([
        ::AlertManagement::AlertPayloadField.new(
          project: project,
          path: 'foo.bar',
          label: 'Bar',
          type: 'string'
        )
      ])
    end

    private

    def success(fields)
      ServiceResponse.success(payload: { payload_alert_fields: fields })
    end

    def error(message)
      ServiceResponse.error(message: message)
    end

    def available?
      feature_enabled? && license_available?
    end

    def feature_enabled?
      Feature.enabled?(:multiple_http_integrations_custom_mapping, project)
    end

    def license_available?
      project&.feature_available?(:multiple_alert_http_integrations)
    end
  end
end
