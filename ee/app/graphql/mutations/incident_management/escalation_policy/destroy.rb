# frozen_string_literal: true

module Mutations
  module IncidentManagement
    module EscalationPolicy
      class Destroy < Base
        graphql_name 'EscalationPolicyDestroy'

        argument :project_path, GraphQL::ID_TYPE,
                 required: true,
                 description: 'The project to remove the escalation policy from.'

        argument :id, Types::GlobalIDType[::IncidentManagement::EscalationPolicy],
                 required: true,
                 description: 'The escalation policy internal ID to remove.'

        def resolve(project_path:, id:)
          escalation_policy = authorized_find!(project_path: project_path, id: id)

          response ::IncidentManagement::EscalationPolicies::DestroyService.new(
            escalation_policy,
            current_user
          ).execute
        end
      end
    end
  end
end
