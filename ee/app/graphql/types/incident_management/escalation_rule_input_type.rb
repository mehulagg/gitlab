# frozen_string_literal: true

module Types
  module IncidentManagement
    class EscalationRuleInputType < BaseInputObject
      graphql_name 'EscalationRuleInput'
      description 'Represents an escalation rule'

      argument :oncall_schedule_id, Types::GlobalIDType[::IncidentManagement::OncallSchedule],
        description: 'The on-call schedule to notify.',
        required: false,
        prepare: ->(id, _) { id.model_id }

      argument :elapsed_time_seconds, GraphQL::INT_TYPE,
        description: 'The time in seconds before the rule is activated.',
        required: true

      argument :status, Types::IncidentManagement::EscalationRuleStatusEnum,
        description: 'The status required to prevent the rule from activating.',
        required: true
    end
  end
end
