# frozen_string_literal: true

module Types
  module IncidentManagement
    # rubocop: disable Graphql/AuthorizeTypes
    class EscalationRuleType < BaseObject
      graphql_name 'EscalationRuleType'
      description 'Represents an escalation rule for an escalation policy'

      field :id, Types::GlobalIDType[::IncidentManagement::EscalationRule],
            null: true,
            description: 'ID of the escalation policy.'

      field :oncall_schedule, Types::IncidentManagement::OncallScheduleType,
            null: true,
            description: 'The on-call schedule to notify.'

      field :elapsed_time_seconds, GraphQL::INT_TYPE,
            null: true,
            description: 'The time in seconds before the rule is activated.'

      field :status, Types::IncidentManagement::EscalationRuleStatusEnum,
            null: true,
            description: 'The status required to prevent the rule from activating.'
    end
    # rubocop: enable Graphql/AuthorizeTypes
  end
end
