# frozen_string_literal: true

module IncidentManagement
  module EscalationPolicyHelper
    def escalation_policy_data
      {
        'empty-escalation-policies-svg-path' => image_path('illustrations/empty-state/empty-escalation.svg')
      }
    end
  end
end
