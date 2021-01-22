# frozen_string_literal: true

module AlertManagement
  # Create alerts coming K8 through gitlab-agent
  class NetworkAlertService
    extend ::Gitlab::Utils::Override
    include ::AlertManagement::AlertProcessing

    MONITORING_TOOL = Gitlab::AlertManagement::Payload::MONITORING_TOOLS.fetch(:cilium)

    def initialize(project, payload)
      @project = project
      @payload = payload
    end

    def execute
      return bad_request unless valid_payload_size?

      process_alert

      return bad_request unless alert.persisted?

      ServiceResponse.success
    end

    private

    attr_reader :project, :payload

    def valid_payload_size?
      Gitlab::Utils::DeepSize.new(payload).valid?
    end

    override :find_existing_alert
    def find_existing_alert
      AlertManagement::Alert
        .not_resolved
        .with_threat_monitoring_alerts
        .for_fingerprint(project, incoming_payload.gitlab_fingerprint)
        .first
    end

    override :build_new_alert
    def build_new_alert
      AlertManagement::Alert.new(
        **incoming_payload.alert_params,
        domain: :threat_monitoring,
        ended_at: nil
      )
    end

    override :incoming_payload
    def incoming_payload
      strong_memoize(:incoming_payload) do
        Gitlab::AlertManagement::Payload.parse(
          project,
          payload,
          monitoring_tool: MONITORING_TOOL
        )
      end
    end

    override :resolving_alert?
    def resolving_alert?
      false
    end

    override :alert_source
    def alert_source
      MONITORING_TOOL
    end

    def bad_request
      ServiceResponse.error(message: 'Bad Request', http_status: :bad_request)
    end
  end
end
