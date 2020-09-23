# frozen_string_literal: true

module EE
  module Gitlab
    module Alerting
      module NotificationPayloadParser
        extend ::Gitlab::Utils::Override

        EXCLUDED_PAYLOAD_FINGERPRINT_PARAMS = %w(start_time end_time hosts).freeze

        # Currently we use full payloads, when generating a fingerprint.
        # This results in a quite strict fingerprint.
        # Over time we can relax these rules.
        # See https://gitlab.com/gitlab-org/gitlab/-/issues/214557#note_362795447
        override :fingerprint
        def fingerprint
          return super if payload[:fingerprint].present? || !generic_alert_fingerprinting_enabled?

          payload_excluding_params = payload.excluding(EXCLUDED_PAYLOAD_FINGERPRINT_PARAMS)

          return if payload_excluding_params.none? { |_, v| v.present? }

          ::Gitlab::AlertManagement::Fingerprint.generate(payload_excluding_params)
        end

        private

        def generic_alert_fingerprinting_enabled?
          project.feature_available?(:generic_alert_fingerprinting)
        end
      end
    end
  end
end
