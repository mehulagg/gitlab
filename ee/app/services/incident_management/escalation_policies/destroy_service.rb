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
        return error_no_license unless available?
        return error_no_permissions unless allowed?

        if escalation_policy.destroy
          success(escalation_policy)
        else
          error(escalation_policy.errors.full_messages.to_sentence)
        end
      end

      private

      attr_reader :escalation_policy, :user, :project

      def error_no_permissions
        error(_('You have insufficient permissions to remove an escalation policy from this project'))
      end
    end
  end
end
