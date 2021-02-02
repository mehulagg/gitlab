# frozen_string_literal: true

# Attribute mapping for alerts via generic alerting integration.
module Gitlab
  module AlertManagement
    module Payload
      class Generic < Base
        DEFAULT_TITLE = 'New: Incident'
        DEFAULT_SEVERITY = 'critical'

        # Overriden in EE
        def self.attribute_paths(default)
          default
        end

        attribute :description, paths: attribute_paths('description')
        attribute :ends_at, paths: attribute_paths('end_time'), type: :time
        attribute :environment_name, paths: attribute_paths('gitlab_environment_name')
        attribute :hosts, paths: attribute_paths('hosts')
        attribute :monitoring_tool, paths: attribute_paths('monitoring_tool')
        attribute :runbook, paths: attribute_paths('runbook')
        attribute :service, paths: attribute_paths('service')
        attribute :severity, paths: attribute_paths('severity'), fallback: -> { DEFAULT_SEVERITY }
        attribute :starts_at, paths: attribute_paths('start_time'), type: :time, fallback: -> { Time.current.utc }
        attribute :title, paths: attribute_paths('title'), fallback: -> { DEFAULT_TITLE }

        attribute :plain_gitlab_fingerprint, paths: attribute_paths('fingerprint')
        private :plain_gitlab_fingerprint

      end
    end
  end
end

Gitlab::AlertManagement::Payload::Generic.prepend_if_ee('EE::Gitlab::AlertManagement::Payload::Generic')
