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

        def find_object(id:)
          GitlabSchema.object_from_id(id, expected_type: ::IncidentManagement::EscalationPolicy)
        end
      end
    end
  end
end
