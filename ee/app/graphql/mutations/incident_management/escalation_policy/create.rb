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
          @project = resolve_project(full_path: project_path).sync

          raise_project_not_found unless project

          args = prepare_rules_attributes(args)

          result = ::IncidentManagement::EscalationPolicies::CreateService.new(
            project,
            current_user,
            args
          ).execute

          response(result)
        end

        private

        attr_reader :project

        def prepare_rules_attributes(args)
          args[:rules_attributes] = args.delete(:rules).map(&:to_h)

          args[:rules_attributes].each do |rule|
            rule[:oncall_schedule_id] = oncall_schedule_id_for_iid(rule.delete(:oncall_schedule_iid))
          end

          args
        end

        def oncall_schedule_id_for_iid(iid)
          # binding.pry
          schedule = ::IncidentManagement::OncallSchedulesFinder.new(current_user, project, iid: iid).execute&.first

          raise Gitlab::Graphql::Errors::ArgumentError, "The oncall schedule for iid #{iid} could not be found" unless schedule

          schedule.id
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
