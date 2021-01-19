# frozen_string_literal: true

module Gitlab
  module AlertManagement
    def self.custom_mapping_available?(project)
      ::Feature.enabled?(:multiple_http_integrations_custom_mapping, project) &&
        project.feature_available?(:multiple_alert_http_integrations)
    end

    def self.custom_mapping_data
      # The complete list of fields can be found in:
      # https://docs.gitlab.com/ee/operations/incident_management/alert_integrations.html#customize-the-alert-payload-outside-of-gitlab

      {
        title: {
          label: 'Title',
          description: 'The title of the incident.',
          types: %w[string]
        },
        description: {
          label: 'Description',
          description: 'A high-level summary of the problem.',
          types: %w[string]
        },
        start_time: {
          label: 'Start time',
          description: 'The time of the incident.',
          types: %w[datetime]
        },
        end_time: {
          label: 'End time',
          description: 'The resolved time of the incident.',
          types: %w[datetime]
        },
        service: {
          label: 'Service',
          description: 'The affected service.',
          types: %w[string]
        },
        monitoring_tool: {
          label: 'Monitoring tool',
          description: 'The name of the associated monitoring tool.',
          types: %w[string]
        },
        hosts: {
          label: 'Hosts',
          description: 'One or more hosts, as to where this incident occurred.',
          types: %w[string array]
        },
        severity: {
          label: 'Severity',
          description: 'The severity of the alert.',
          types: %w[string]
        },
        fingerprint: {
          label: 'Fingerprint',
          description: 'The unique identifier of the alert. This can be used to group occurrences of the same alert.',
          types: %w[string array]
        },
        gitlab_environment_name: {
          label: 'Environment',
          description: 'The name of the associated GitLab environment.',
          types: %w[string]
        }
      }
    end
  end
end
