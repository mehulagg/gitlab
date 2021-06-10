# frozen_string_literal: true

module IncidentManagement
  module EscalationPolicies
    class CreateService < EscalationPolicies::BaseService
      # @param [Project] project
      # @param [User] user
      # @param [Hash] params
      # @option params [String] name
      # @option params [String] description
      # @option params [Array<Hash>] rules_attributes
      # @option rules [Integer] oncall_schedule_id
      # @option rules [Integer] elapsed_time_seconds
      # @option rules [String] status
      def initialize(project, user, params)
        @project = project
        @user = user
        @params = params
      end

      def execute
        return error_no_license unless available?
        return error_no_permissions unless allowed?
        return error_no_rules if params[:rules_attributes].blank?

        escalation_policy = project.incident_management_escalation_policies.create(params)

        return error_in_create(escalation_policy) unless escalation_policy.persisted?

        success(escalation_policy)
      end

      private

      attr_reader :project, :user, :params

      def error_no_permissions
        error(_('You have insufficient permissions to create an escalation policy for this project'))
      end

      def error_in_create(escalation_policy)
        error(escalation_policy.errors.full_messages.to_sentence)
      end

      def error_no_rules
        error(_('A rule must be provided to create an escalation policy'))
      end
    end
  end
end
