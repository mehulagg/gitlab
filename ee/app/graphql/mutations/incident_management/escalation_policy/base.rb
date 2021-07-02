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
          GitlabSchema.object_from_id(id, expected_type: ::IncidentManagement::EscalationPolicy).sync
        end

        # Provide more granular error message for feature availability
        # ahead of role-based authorization
        def authorize!(object)
          raise_feature_not_available! if object && !escalation_policies_available?(object)

          super
        end

        def raise_feature_not_available!
          raise_resource_not_available_error! 'Escalation policies are not supported for this project'
        end

        def escalation_policies_available?(policy)
          ::Gitlab::IncidentManagement.escalation_policies_available?(policy.project)
        end

        def prepare_rules_attributes(project, args)
          return args unless rules = args.delete(:rules)

          rules_attributes = prepare_oncall_schedule_iids(project, rules)
          rules_attributes = prepare_user_ids(project, rules_attributes)

          args.merge(rules_attributes: rules_attributes)
        end

        def prepare_oncall_schedule_iids(project, rules)
          iids = rules.collect { |rule| rule[:oncall_schedule_iid] }
          found_schedules = schedules_for_iids(project, iids)

          rules.map { |rule| prepare_rule(found_schedules, rule.to_h) }
        end

        def prepare_user_ids(project, rules)
          usernames = rules.collect { |rule| rule[:username] }
          matched_users = UsersFinder.new(current_user, username: usernames).execute.index_by(&:username)

          rules.map { |rule| prepare_user(matched_users, rule.to_h) }
        end

        def prepare_user(users, rule)
          username = rule.delete(:username)

          rule.merge(user: users[username])
        end

        def prepare_rule(schedules, rule)
          iid = rule.delete(:oncall_schedule_iid).to_i

          rule.merge(oncall_schedule: schedules[iid])
        end

        def schedules_for_iids(project, iids)
          schedules = ::IncidentManagement::OncallSchedulesFinder.new(current_user, project, iid: iids).execute

          schedules.index_by(&:iid)
        end
      end
    end
  end
end
