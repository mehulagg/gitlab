# frozen_string_literal: true

module Mutations
  module IncidentManagement
    module EscalationPolicy
      class Update < Base
        graphql_name 'EscalationPolicyUpdate'

        argument :id, ::Types::GlobalIDType[::IncidentManagement::EscalationPolicy],
                 required: true,
                 description: 'The ID of the on-call schedule to create the on-call rotation in.'

        argument :name, GraphQL::STRING_TYPE,
                required: false,
                description: 'The name of the escalation policy.'

        argument :description, GraphQL::STRING_TYPE,
                required: false,
                description: 'The description of the escalation policy.'

        argument :rules, [Types::IncidentManagement::EscalationRuleInputType],
                required: false,
                description: 'The steps of the escalation policy.'

        def resolve(id:, **args)
          policy = authorized_find!(id: id)
          @project = policy.project

          result = ::IncidentManagement::EscalationPolicy::UpdateService.new(
            policy,
            current_user,
            prepare_attributes(args)
          ).execute

          response(result)
        end

        private

        def find_object(id:)
          GitlabSchema.object_from_id(id, expected_type: ::IncidentManagement::EscalationPolicy)
        end
      end
    end
  end
end
