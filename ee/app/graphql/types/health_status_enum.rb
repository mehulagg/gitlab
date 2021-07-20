# frozen_string_literal: true

module Types
  class HealthStatusEnum < BaseEnum
    graphql_name 'HealthStatus'
    description 'Health status of an issue or epic'

    Issue.health_statuses.each do |status, val|
      value status.camelize(:lower), description: status.humanize, value: status
    end
  end
end
