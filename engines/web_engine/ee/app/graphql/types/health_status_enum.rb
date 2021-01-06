# frozen_string_literal: true

module Types
  class HealthStatusEnum < BaseEnum
    graphql_name 'HealthStatus'
    description 'Health status of an issue or epic'

    value 'onTrack', value: Issue.health_statuses.key(1)
    value 'needsAttention', value: Issue.health_statuses.key(2)
    value 'atRisk', value: Issue.health_statuses.key(3)
  end
end
