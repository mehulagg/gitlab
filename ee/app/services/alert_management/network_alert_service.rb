# frozen_string_literal: true

module AlertManagement
  # Create alerts coming K8 through gitlab-agent
  class NetworkAlertService
    include Gitlab::Utils::StrongMemoize

    MONITORING_TOOL = Gitlab::AlertManagement::Payload::MONITORING_TOOLS.fetch(:cilium)

    def initialize(project, payload)
      @project = project
      @payload = payload
    end

    # Users of this service need to check the agent token before calling `execute`.
    # https://gitlab.com/gitlab-org/gitlab/-/issues/292707 will handle token within the service.
    def execute
      return bad_request unless valid_payload_size?

      process_request

      return bad_request unless alert.persisted?

      ServiceResponse.success
    end

    private

    attr_reader :project, :payload

    def valid_payload_size?
      Gitlab::Utils::DeepSize.new(payload).valid?
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

    def incoming_payload
      strong_memoize(:incoming_payload) do
        Gitlab::AlertManagement::Payload.parse(project, payload, monitoring_tool: MONITORING_TOOL)
      end
    end

    def bad_request
      ServiceResponse.error(message: 'Bad Request', http_status: :bad_request)
    end
  end
end
