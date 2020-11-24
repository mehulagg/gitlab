# frozen_string_literal: true

module AlertManagement
  # Create alerts coming K8 through gitlab-agent
  class NetworkAlertService < BaseService
    include Gitlab::Utils::StrongMemoize
    include ::IncidentManagement::Settings

    def execute
      return bad_request unless valid_payload_size?

      process_request

      return bad_request unless alert.persisted?

      ServiceResponse.success
    end

    private

    def valid_payload_size?
      Gitlab::Utils::DeepSize.new(params).valid?
    end

    def process_request
      alert.persisted? ? process_existing_alert : create_alert
    end

    def process_existing_alert
      incoming_payload.ends_at.present? ? process_resolved_alert : alert.register_new_event!

      alert
    end

    def create_alert
      if alert.save
        alert.execute_services
        SystemNoteService.create_new_alert(
          alert,
          Gitlab::AlertManagement::Payload::MONITORING_TOOLS[:cilium]
        )
        return
      end

      logger.warn(
        message:
          "Unable to create AlertManagement::Alert from #{
            Gitlab::AlertManagement::Payload::MONITORING_TOOLS[:cilium]
          }",
        project_id: project.id,
        alert_errors: alert.errors.messages
      )
    end

    def process_resolved_alert
      return unless auto_close_incident?

      close_issue(alert.issue) if alert.resolve(incoming_payload.ends_at)

      alert
    end

    def close_issue(issue)
      return if issue.blank? || issue.closed?

      ::Issues::CloseService.new(project, User.alert_bot).execute(issue, system_note: false)

      if issue.reset.closed?
        SystemNoteService.auto_resolve_prometheus_alert(issue, project, User.alert_bot)
      end
    end

    def logger
      @logger ||= Gitlab::AppLogger
    end

    def alert
      strong_memoize(:alert) { existing_alert || new_alert }
    end

    def existing_alert
      strong_memoize(:existing_alert) do
        AlertManagement::Alert.not_resolved.for_fingerprint(
          project,
          incoming_payload.gitlab_fingerprint
        ).first
      end
    end

    def new_alert
      strong_memoize(:new_alert) do
        AlertManagement::Alert.new(**incoming_payload.alert_params, ended_at: nil)
      end
    end

    def incoming_payload
      strong_memoize(:incoming_payload) do
        Gitlab::AlertManagement::Payload.parse(
          project,
          params,
          monitoring_tool: Gitlab::AlertManagement::Payload::MONITORING_TOOLS[:cilium]
        )
      end
    end

    def bad_request
      ServiceResponse.error(message: 'Bad Request', http_status: :bad_request)
    end
  end
end
