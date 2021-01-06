# frozen_string_literal: true

module AlertManagement
  class ExtractAlertPayloadFieldsService < BaseContainerService
    alias_method :project, :container

    def execute
      return error('Feature not available') unless available?
      return error('Insufficient permissions') unless allowed?

      payload = parse_payload
      return error('Failed to parse payload') unless payload && payload.is_a?(Hash)
      return error('Payload size exceeded') unless valid_payload_size?(payload)

      fields = Gitlab::AlertManagement::AlertPayloadFieldExtractor
        .new(project).extract(payload)

      success(fields)
    end

    private

    def parse_payload
      Gitlab::Json.parse(params[:payload])
    rescue JSON::ParserError
    end

    def valid_payload_size?(payload)
      Gitlab::Utils::DeepSize.new(payload).valid?
    end

    def success(fields)
      ServiceResponse.success(payload: { payload_alert_fields: fields })
    end

    def error(message)
      ServiceResponse.error(message: message)
    end

    def available?
      feature_enabled? && license_available?
    end

    def allowed?
      current_user&.can?(:admin_operations, project)
    end

    def feature_enabled?
      Feature.enabled?(:multiple_http_integrations_custom_mapping, project)
    end

    def license_available?
      project&.feature_available?(:multiple_alert_http_integrations)
    end
  end
end
