# frozen_string_literal: true

module AlertManagement
  # Create alerts coming K8 through gitlab-agent
  class NetworkAlertService < BaseService
    include Gitlab::Utils::StrongMemoize
    include ::IncidentManagement::Settings

    MONITORING_TOOL = Gitlab::AlertManagement::Payload::MONITORING_TOOLS.fetch(:cilium)

    # https://gitlab.com/gitlab-org/gitlab/-/issues/292707
    def execute
      return bad_request unless valid_payload_size?

      # Not meant to run with a user, but with a agent
      # See https://gitlab.com/gitlab-org/gitlab/-/issues/291986
      process_request

      return bad_request unless alert.persisted?

      ServiceResponse.success
    end

    private

    def valid_payload_size?
      Gitlab::Utils::DeepSize.new(params).valid?
    end

    def process_request
      if alert.persisted?
        alert.register_new_event!
      else
        create_alert
      end
    end

    def create_alert
      if alert.save
        alert.execute_services
        SystemNoteService.create_new_alert(
          alert,
          MONITORING_TOOL
        )
        return
      end

      logger.warn(
        message:
          "Unable to create AlertManagement::Alert from #{MONITORING_TOOL}",
        project_id: project.id,
        alert_errors: alert.errors.messages
      )
    end

    def logger
      @logger ||= Gitlab::AppLogger
    end

    def alert
      strong_memoize(:alert) { find_existing_alert || build_new_alert }
    end

    def find_existing_alert
      AlertManagement::Alert.not_resolved.for_fingerprint(
        project,
        incoming_payload.gitlab_fingerprint
      ).first
    end

    def build_new_alert
      AlertManagement::Alert.new(**incoming_payload.alert_params, domain: :threat_monitoring, ended_at: nil)
    end

    # https://gitlab.com/gitlab-org/gitlab/-/issues/292034
    def incoming_payload
      strong_memoize(:incoming_payload) do
        Gitlab::AlertManagement::Payload.parse(
          project,
          params,
          monitoring_tool: MONITORING_TOOL
        )
      end
    end

    def bad_request
      ServiceResponse.error(message: 'Bad Request', http_status: :bad_request)
    end
  end
end
