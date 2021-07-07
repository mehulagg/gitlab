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

          schedules = collect_schedules(project, rules)
          users = collect_users(project, rules)
          rules_attributes = rules.map { |rule| prepare_rule(rule.to_h, schedules, users) }

          args.merge(rules_attributes: rules_attributes)
        end

        def prepare_rule(rule, schedules, users)
          schedule_iid = rule.delete(:oncall_schedule_iid).to_i
          username = rule.delete(:username)

          rule.merge(oncall_schedule: schedules[schedule_iid], user: users[username])
        end

        def collect_schedules(project, rules)
          iids = rules.filter_map { |rule| rule[:oncall_schedule_iid]&.to_i }

          schedules = ::IncidentManagement::OncallSchedulesFinder
            .new(current_user, project, iid: iids)
            .execute
            .index_by(&:iid)

          if missing_iids = (iids - schedules.keys).presence
            raise_resource_not_available_error! "On-call schedules unavailable for iids #{missing_iids.join(', ')}"
          end

          schedules
        end

        def collect_users(project, rules)
          usernames = rules.filter_map { |rule| rule[:username] }

          UsersFinder
            .new(current_user, username: usernames)
            .execute
            .index_by(&:username)
        end
      end
    end
  end
end
