# frozen_string_literal: true

module Mutations
  module IncidentManagement
    module EscalationPolicy
      class Create < BaseMutation
        include ResolvesProject

        graphql_name 'EscalationPolicyCreate'

        field :escalation_policy,
              ::Types::IncidentManagement::EscalationPolicyType,
              null: true,
              description: 'The escalation policy.'

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
          project = resolve_project(full_path: project_path).sync

          raise_project_not_found unless project

          args[:rules_attributes] = args.delete(:rules).map(&:to_h)

          result = ::IncidentManagement::EscalationPolicies::CreateService.new(
            project,
            current_user,
            args
          ).execute

          response(result)
        end

        def response(result)
          {
            escalation_policy: result.payload[:escalation_policy],
            errors: result.errors
          }
        end

        def raise_project_not_found
          raise Gitlab::Graphql::Errors::ArgumentError, 'The project could not be found'
        end
      end
    end
  end
end
