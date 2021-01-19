# frozen_string_literal: true

module Gitlab
  module AlertManagement
    module Payload
      class Cilium < Base
        DEFAULT_TITLE = 'New: Alert'

        attribute :description, paths: %w(alert flow drop_reason_desc)
        attribute :status, paths: %w(alert ciliumNetworkPolicy status)
        attribute :title, paths: %w(alert ciliumNetworkPolicy metadata name), fallback: -> { DEFAULT_TITLE }

        def monitoring_tool
          Gitlab::AlertManagement::Payload::MONITORING_TOOLS[:cilium]
        end
      end
    end
  end
end
