# frozen_string_literal: true

module Resolvers
  module IncidentManagement
    class EscalationPoliciesResolver < BaseResolver
      alias_method :project, :object

      type Types::IncidentManagement::EscalationPolicyType.connection_type, null: true

      when_single do
        argument :id,
                 ::Types::GlobalIDType[::IncidentManagement::EscalationPolicy],
                 required: true,
                 description: 'ID of the escalation policy.',
                 prepare: ->(id, ctx) { id.model_id }
      end

      def resolve(**args)
        ::IncidentManagement::EscalationPoliciesFinder.new(context[:current_user], project, args).execute
      end
    end
  end
end
