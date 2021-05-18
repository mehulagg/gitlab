# frozen_string_literal: true

module Mutations
  module IncidentManagement
    module EscalationPolicy
      class Base < BaseMutation
        field :escalation_policy,
              ::Types::IncidentManagement::EscalationPolicyType,
              null: true,
              description: 'The escalation policy.'

        authorize :admin_incident_management_escalation_policy

        private

        def response(result)
          {
            escalation_policy: result.payload[:escalation_policy],
            errors: result.errors
          }
        end

        def find_object(project_path:, id:)
          project = Project.find_by_full_path(project_path)

          return unless project

          ::IncidentManagement::EscalationPoliciesFinder.new(current_user, project, id: id.model_id).execute.first
        end
      end
    end
  end
end
