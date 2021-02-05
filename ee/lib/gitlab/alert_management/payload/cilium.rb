# frozen_string_literal: true

module Gitlab
  module AlertManagement
    module Payload
      class Cilium < Gitlab::AlertManagement::Payload::Generic
        DEFAULT_TITLE = 'New: Alert'

        attribute :description, paths: %w(flow dropReasonDesc)
        attribute :title, paths: %w(ciliumNetworkPolicy metadata name), fallback: -> { DEFAULT_TITLE }
        attribute :gitlab_fingerprint, paths: %w(fingerprint)

        def monitoring_tool
          Gitlab::AlertManagement::Payload::MONITORING_TOOLS[:cilium]
        end
      end
    end
  end
end
