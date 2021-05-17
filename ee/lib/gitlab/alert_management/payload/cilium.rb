# frozen_string_literal: true

module Gitlab
  module AlertManagement
    module Payload
      class Cilium < Gitlab::AlertManagement::Payload::Generic
        attribute :description, paths: %w(flow verdict)
        attribute :title, paths: %w(ciliumNetworkPolicy metadata name), fallback: -> { DEFAULT_TITLE }

        def monitoring_tool
          Gitlab::AlertManagement::Payload::MONITORING_TOOLS[:cilium]
        end

        private

        def plain_gitlab_fingerprint
          fpayload = self.payload.deep_dup
          fpayload = fpayload['flow'].except('time', 'Summary')
          fpayload['l4']['TCP'].delete('flags') if fpayload.dig('l4', 'TCP', 'flags')

          fpayload.to_json
        end
      end
    end
  end
end
