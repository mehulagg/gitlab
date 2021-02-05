# frozen_string_literal: true

module Gitlab
  module AlertManagement
    module Payload
      MONITORING_TOOLS = {
        prometheus: 'Prometheus',
        cilium: 'Cilium'
      }.freeze

      class << self
        # Instantiates an instance of a subclass of
        # Gitlab::AlertManagement::Payload::Base. This can
        # be used to create new alerts or read content from
        # the payload of an existing AlertManagement::Alert
        #
        # @param project [Project]
        # @param payload [Hash]
        # @param monitoring_tool [String]
        def parse(project, payload, monitoring_tool: nil)
          payload_class = payload_class_for(
            monitoring_tool: monitoring_tool || payload&.dig('monitoring_tool'),
            payload: payload
          )

          payload_class.new(project: project, payload: payload)
        end

        private

        def payload_class_for(monitoring_tool:, payload:)
          if monitoring_tool == MONITORING_TOOLS[:prometheus]
            if gitlab_managed_prometheus?(payload)
              ::Gitlab::AlertManagement::Payload::ManagedPrometheus
            else
              ::Gitlab::AlertManagement::Payload::Prometheus
            end
          else
            ::Gitlab::AlertManagement::Payload::Generic
          end
        end

        def gitlab_managed_prometheus?(payload)
          payload&.dig('labels', 'gitlab_alert_id').present?
        end
      end
    end
  end
end

Gitlab::AlertManagement::Payload.prepend_if_ee('EE::Gitlab::AlertManagement::Payload')
