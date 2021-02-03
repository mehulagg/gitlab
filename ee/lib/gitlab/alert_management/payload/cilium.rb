# frozen_string_literal: true

module Gitlab
  module AlertManagement
    module Payload
      class Cilium < Gitlab::AlertManagement::Payload::Generic
        DEFAULT_TITLE = 'New: Alert'

        attribute :description, paths: %w(flow verdict)
        attribute :title, paths: %w(ciliumNetworkPolicy metadata name), fallback: -> { DEFAULT_TITLE }

        def monitoring_tool
          Gitlab::AlertManagement::Payload::MONITORING_TOOLS[:cilium]
        end

        private

        def plain_gitlab_fingerprint
          payload = self.payload
          payload = payload['flow'].except('time', 'Summary')
          payload['l4']['TCP'].delete('flags') if payload.dig('l4', 'TCP', 'flags')

          payload.to_s
        end
      end
    end
  end
end
