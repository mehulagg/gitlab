# frozen_string_literal: true

module Types
  module IncidentManagement
    class EscalationRuleStatusEnum < BaseEnum
      graphql_name 'EscalationRuleStatus'
      description 'Escalation rule statuses'

      ::IncidentManagement::EscalationRule.statuses.each_key do |status|
        value status.to_s.upcase, value: status, description: "#{::AlertManagement::Alert::STATUS_DESCRIPTIONS[status]}."
      end
    end
  end
end
