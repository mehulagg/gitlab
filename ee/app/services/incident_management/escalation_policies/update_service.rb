# frozen_string_literal: true

module IncidentManagement
  module EscalationPolicies
    class UpdateService < EscalationPolicies::BaseService
      include Gitlab::Utils::StrongMemoize

      # @param escalation_policy [IncidentManagement::EscalationPolicy]
      # @param user [User]
      # @param params [Hash]
      # @option params [String] name
      # @option params [String] description
      # @option params [Array<Hash>] rules_attributes
      #                              The attributes of the full set of
      #                              the policy's expected escalation rules.
      # @option params[:rules_attributes] [IncidentManagement::OncallSchedule] oncall_schedule
      # @option params[:rules_attributes] [Integer] elapsed_time_seconds
      # @option params[:rules_attributes] [String, Integer, Symbol] status
      def initialize(escalation_policy, user, params)
        @escalation_policy = escalation_policy
        @user = user
        @params = params
        @project = escalation_policy.project
      end

      def execute
        return error_no_permissions unless allowed?
        return error_no_rules if empty_rules?
        return error_too_many_rules if too_many_rules?
        return error_bad_schedules if invalid_schedules?

        reconcile_rules!

        if escalation_policy.update(params)
          success(escalation_policy)
        else
          error_in_save(escalation_policy)
        end
      end

      private

      attr_reader :escalation_policy, :user, :params, :project

      def empty_rules?
        params[:rules_attributes] && params[:rules_attributes].empty?
      end

      # Limits rules_attributes to only new records & prepares
      # to delete existing rules which are no longer needed
      # when the policy is saved.
      #
      # Context: Rules are managed via `accepts_nested_attributes_for`
      # on the IncidentManagement::EscalationPolicy.
      # `accepts_nested_attributes_for` requires explicit
      # removal of records, so we'll limit `rules_attributes`
      # to new records, then rely on `autosave` to actually
      # destroy the unwanted rules after marking them for
      # deletion.
      def reconcile_rules!
        return unless rules_attributes = params.delete(:rules_attributes)

        params[:rules_attributes] = remove_obsolete_rules(rules_attributes).to_a
      end

      def remove_obsolete_rules(rules_attrs)
        expected_rules = rules_attrs.to_set { |attrs| normalize(::IncidentManagement::EscalationRule.new(**attrs)) }

        escalation_policy.rules.each_with_object(expected_rules) do |existing_rule, new_rules|
          # Exclude an expected rule which already corresponds to a persisted record - it's a no-op.
          next if new_rules.delete?(normalize(existing_rule))

          # Destroy a persisted record, since we don't expect this rule to be on the policy anymore.
          existing_rule.mark_for_destruction
        end
      end

      def normalize(rule)
        rule.slice(:oncall_schedule_id, :elapsed_time_seconds, :status)
      end
    end
  end
end
