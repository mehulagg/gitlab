# frozen_string_literal: true

module Mutations
  module IncidentManagement
    module EscalationPolicy
      class Base < BaseMutation
        authorize :admin_incident_management_escalation_policy

        field :escalation_policy,
              ::Types::IncidentManagement::EscalationPolicyType,
              null: true,
              description: 'The escalation policy.'

        private

        attr_reader :project

        def response(result)
          {
            escalation_policy: result.payload[:escalation_policy],
            errors: result.errors
          }
        end

        def find_object(id:)
          GitlabSchema.object_from_id(id, expected_type: ::IncidentManagement::EscalationPolicy)
        end

        def authorize!(object)
          unless ::Gitlab::IncidentManagement.escalation_policies_available?(object)
            raise_resource_not_available_error! 'Escalation policies are not supported for this project'
          end

          super
        end

        def prepare_attributes(args)
          if rules = args.delete(:rules).presence
            args[:rules_attributes] = prepare_rules(rules.map(&:to_h))
          end

          args
        end

        def prepare_rules(rules)
          iids = rules.collect { |rule| rule[:oncall_schedule_iid] }
          found_schedules = schedules_for_iids(iids)

          rules.each do |rule|
            iid = rule.delete(:oncall_schedule_iid).to_i
            rule[:oncall_schedule] = found_schedules[iid]

            raise_schedule_not_found!(iid) unless rule[:oncall_schedule]
          end

          rules
        end

        def schedules_for_iids(iids)
          schedules = ::IncidentManagement::OncallSchedulesFinder.new(current_user, project, iid: iids).execute

          schedules.index_by(&:iid)
        end

        def raise_schedule_not_found!(iid)
          raise Gitlab::Graphql::Errors::ResourceNotAvailable, "The oncall schedule for iid #{iid} could not be found"
        end
      end
    end
  end
end
