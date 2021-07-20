# frozen_string_literal: true

module IncidentManagement
  module EscalationPolicies
    class DestroyService < EscalationPolicies::BaseService
      # @param escalation_policy [IncidentManagement::EscalationPolicy]
      # @param user [User]
      def initialize(escalation_policy, user)
        @escalation_policy = escalation_policy
        @user = user
        @project = escalation_policy.project
      end

      def execute
        return error_no_permissions unless allowed?

        if escalation_policy.destroy
          success(escalation_policy)
        else
          error_in_save(escalation_policy)
        end
      end

      private

      attr_reader :escalation_policy, :user, :project
    end
  end
end
