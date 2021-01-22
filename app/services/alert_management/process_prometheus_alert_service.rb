# frozen_string_literal: true

module AlertManagement
  class ProcessPrometheusAlertService
    extend ::Gitlab::Utils::Override
    include ::AlertManagement::AlertProcessing

    def initialize(project, payload)
      @project = project
      @payload = payload
    end

    def execute
      return bad_request unless incoming_payload.has_required_attributes?

      process_alert
      return bad_request unless alert.persisted?

      complete_post_processing_tasks

      ServiceResponse.success
    end

    private

    attr_reader :project, :payload

    override :process_new_alert
    def process_new_alert
      # TODO: Should "resolved" alerts which have not
      #       been received before be created & resolved?
      #       Or just skipped, as it is now?
      return if resolving_alert?

      super
    end

    override :process_firing_alert
    def process_firing_alert
      super

      reset_alert_status
    end

    # TODO: Should we be doing this? This would turn an
    # acknowledged alert back to triggered, but that doesn't
    # really seem right
    def reset_alert_status
      return if alert.trigger

      logger.warn(
        message: 'Unable to update AlertManagement::Alert status to triggered',
        project_id: project.id,
        alert_id: alert.id
      )
    end

    override :incoming_payload
    def incoming_payload
      strong_memoize(:incoming_payload) do
        Gitlab::AlertManagement::Payload.parse(
          project,
          payload,
          monitoring_tool: Gitlab::AlertManagement::Payload::MONITORING_TOOLS[:prometheus]
        )
      end
    end

    override :resolving_alert?
    def resolving_alert?
      incoming_payload.resolved?
    end

    def bad_request
      ServiceResponse.error(message: 'Bad Request', http_status: :bad_request)
    end
  end
end
