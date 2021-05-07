# frozen_string_literal: true

module EE
  module Gitlab
    module AlertManagement
      module Payload
        extend ActiveSupport::Concern

        class_methods do
          extend ::Gitlab::Utils::Override

          private

          override :payload_class_for
          def payload_class_for(monitoring_tool:, payload:)
            if monitoring_tool == ::Gitlab::AlertManagement::Payload::MONITORING_TOOLS[:cilium]
              ::Gitlab::AlertManagement::Payload::Cilium
            else
              super
            end
          end
        end
      end
    end
  end
end
