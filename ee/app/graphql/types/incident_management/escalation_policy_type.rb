# frozen_string_literal: true

module Types
  module IncidentManagement
    class EscalationPolicyType < BaseObject
      graphql_name 'EscalationPolicyType'
      description 'Represents an escalation policy'

      authorize :read_incident_management_escalation_policy

      field :id,
            Types::GlobalIDType[::IncidentManagement::EscalationPolicy],
            null: false,
            description: 'ID of the escalation policy.'

      field :name, GraphQL::STRING_TYPE,
                null: false,
                description: 'The name of the escalation policy.'

      field :description, GraphQL::STRING_TYPE,
                null: true,
                description: 'The description of the escalation policy.'

      field :rules, [Types::IncidentManagement::EscalationRuleType],
                null: true,
                description: 'The color weight to assign to for the on-call user, for example "500". Max 4 chars. For easy identification of the user.'
    end
  end
end
