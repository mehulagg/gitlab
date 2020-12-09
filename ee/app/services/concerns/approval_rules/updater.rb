# frozen_string_literal: true

module ApprovalRules
  module Updater
    include ::Audit::Changes

    def action
      filter_eligible_users!
      filter_eligible_groups!
      filter_eligible_protected_branches!

      if with_audit_logged { rule.update(params) }
        log_audit_event(rule)
        rule.reset

        update_umodified_mr_approval_rules(rule)

        success
      else
        error(rule.errors.messages)
      end
    end

    private

    # Update all the MR rules related to this project rule where
    #   "modified_from_project_rule" is false and the MR is unmerged
    #
    def update_umodified_mr_approval_rules(rule)
      return unless rule.is_a?(ApprovalProjectRule)

      # Find all unmodified MR rules based on this project rule for unmerged MRs
      #
      unmodified_rules = rule
        .approval_merge_request_rules
        .for_unmerged_merge_requests
        .where(modified_from_project_rule: false) # rubocop: disable CodeReuse/ActiveRecord

      if unmodified_rules.any?
        params = {
          name: rule.name,
          approvals_required: rule.approvals_required,
          user_ids: rule.users.collect(&:id),
          group_ids: rule.groups.collect(&:id)
        }

        unmodified_rules.each do |mr_rule|
          ::ApprovalRules::UpdateService.new(mr_rule, current_user, params).execute
        end
      end
    end

    def with_audit_logged(&block)
      audit_context = {
        name: 'update_aproval_rules',
        author: current_user,
        scope: rule.project,
        target: rule
      }

      ::Gitlab::Audit::Auditor.audit(audit_context, &block)
    end

    def filter_eligible_users!
      return unless params.key?(:user_ids)

      params[:users] = project.members_among(User.id_in(params.delete(:user_ids)))
    end

    def filter_eligible_groups!
      return unless params.key?(:group_ids)

      params[:groups] = Group.id_in(params.delete(:group_ids)).public_or_visible_to_user(current_user)
    end

    def filter_eligible_protected_branches!
      return unless params.key?(:protected_branch_ids)

      protected_branch_ids = params.delete(:protected_branch_ids)

      return unless project.multiple_approval_rules_available? && can?(current_user, :admin_project, project)

      params[:protected_branches] =
        ProtectedBranch
          .id_in(protected_branch_ids)
          .for_project(project)
    end

    def log_audit_event(rule)
      audit_changes(
        :approvals_required,
        as: 'number of required approvals',
        entity: rule.project,
        model: rule
      )
    end
  end
end
