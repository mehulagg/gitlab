# frozen_string_literal: true

module IncidentManagement
  module EscalationPolicyHelper
    def escalation_policy_data(project)
      {
          'project-path' => project.full_path,
          'empty_escalation_policies_svg_path' => image_path('illustrations/empty-state/empty-escalation.svg')
      }
    end
  end
end
