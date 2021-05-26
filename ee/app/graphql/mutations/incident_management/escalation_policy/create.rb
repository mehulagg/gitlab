# frozen_string_literal: true

module Mutations
  module IncidentManagement
    module EscalationPolicy
      class Create < Base
        include ResolvesProject

        graphql_name 'EscalationPolicyCreate'

        argument :project_path, GraphQL::ID_TYPE,
                 required: true,
                 description: 'The project to create the escalation policy for.'

        argument :name, GraphQL::STRING_TYPE,
                 required: true,
                 description: 'The name of the escalation policy.'

        argument :description, GraphQL::STRING_TYPE,
                 required: false,
                 description: 'The description of the escalation policy.'

        argument :rules, [Types::IncidentManagement::EscalationRuleInputType],
                 required: true,
                 description: 'The steps of the escalation policy.'

        def resolve(project_path:, **args)
          @project = authorized_find!(project_path: project_path, **args)

          result = ::IncidentManagement::EscalationPolicies::CreateService.new(
            project,
            current_user,
            prepare_attributes(args)
          ).execute

          response(result)
        end

        private

        def find_object(project_path:, **args)
          project = resolve_project(full_path: project_path).sync

          raise_project_not_found unless project

          project
        end

        def raise_project_not_found
          raise Gitlab::Graphql::Errors::ResourceNotAvailable, 'The project could not be found'
        end
      end
    end
  end
end
