# frozen_string_literal: true

module Types
  module AlertManagement
    class PayloadAlertFieldNameEnum < BaseEnum
      graphql_name 'AlertManagementPayloadAlertFieldName'
      description 'Values for alert field names used in the custom mapping'

      # The complete list of fields can be found in:
      # https://docs.gitlab.com/ee/operations/incident_management/alert_integrations.html#customize-the-alert-payload-outside-of-gitlab
      value 'TITLE', 'The title of the incident.', value: 'title'
      value 'DESCRIPTION', 'A high-level summary of the problem.', value: 'description'
      value 'START_TIME', 'The time of the incident.', value: 'start_time'
      value 'END_TIME', 'The resolved time of the incident.', value: 'end_time'
      value 'SERVICE', 'The affected service.', value: 'service'
      value 'MONITORING_TOOL', 'The name of the associated monitoring tool.', value: 'monitoring_tool'
      value 'HOSTS', 'One or more hosts, as to where this incident occurred.', value: 'hosts'
      value 'SEVERITY', 'The severity of the alert.', value: 'severity'
      value 'FINGERPRINT', 'The unique identifier of the alert. This can be used to group occurrences of the same alert.', value: 'fingerprint'
      value 'GITLAB_ENVIRONMENT_NAME', 'The name of the associated GitLab environment.', value: 'gitlab_environment_name'
    end
  end
end
