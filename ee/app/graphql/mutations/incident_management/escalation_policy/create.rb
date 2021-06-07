# frozen_string_literal: true

module Mutations
  module IncidentManagement
    module EscalationPolicy
      class Create < BaseMutation
        include ResolvesProject

        graphql_name 'EscalationPolicyCreate'

        authorize :admin_incident_management_escalation_policy

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
          @project = authorized_find!(project_path: project_path, **args)

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

        def find_object(project_path:, **args)
          unless project = resolve_project(full_path: project_path).sync
            raise_project_not_found
          end

          unless ::Gitlab::IncidentManagement.escalation_policies_available?(project)
            raise_resource_not_available_error! 'Escalation policies are not supported for this project'
          end

          project
        end

        def prepare_rules_attributes(args)
          args[:rules_attributes] = args.delete(:rules).map(&:to_h)

          iids = args[:rules_attributes].collect { |rule| rule[:oncall_schedule_iid] }
          found_schedules = schedules_for_iids(iids)

          args[:rules_attributes].each do |rule|
            iid = rule.delete(:oncall_schedule_iid).to_i
            rule[:oncall_schedule] = found_schedules[iid]

            raise Gitlab::Graphql::Errors::ResourceNotAvailable, "The oncall schedule for iid #{iid} could not be found" unless rule[:oncall_schedule]
          end

          args
        end

        def schedules_for_iids(iids)
          schedules = ::IncidentManagement::OncallSchedulesFinder.new(current_user, project, iid: iids).execute

          schedules.index_by(&:iid)
        end

        def response(result)
          {
            escalation_policy: result.payload[:escalation_policy],
            errors: result.errors
          }
        end

        def raise_project_not_found
          raise Gitlab::Graphql::Errors::ResourceNotAvailable, 'The project could not be found'
        end
      end
    end
  end
end
