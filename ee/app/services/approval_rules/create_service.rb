# frozen_string_literal: true

module ApprovalRules
  class CreateService < ::ApprovalRules::BaseService
    include ::ApprovalRules::Updater

    # @param target [Project, MergeRequest]
    def initialize(target, user, params)
      @rule = target.approval_rules.build
      @params = params

      # report_approver rule_type is currently auto-set according to rulename
      # Techdebt to be addressed with: https://gitlab.com/gitlab-org/gitlab/issues/12759
      if target.is_a?(Project) && ApprovalProjectRule::REPORT_TYPES_BY_DEFAULT_NAME.key?(params[:name])
        params.reverse_merge!(rule_type: :report_approver)
      end

      # If merge request approvers are specified, they take precedence over project
      # approvers.
      copy_approval_project_rule_properties(params) if target.is_a?(MergeRequest)
      handle_any_approver_rule_creation(target, @rule.project, params)

      super(@rule.project, user, params)
    end

    private

    def copy_approval_project_rule_properties(params)
      return if params[:approval_project_rule_id].blank?

      approval_project_rule = @rule.project.approval_rules.find_by_id(params[:approval_project_rule_id])

      return if approval_project_rule.blank?

      params[:name] = approval_project_rule.name

      unless approvers_set?
        params[:users] = approval_project_rule.users
        params[:groups] = approval_project_rule.groups
      end
    end

    def handle_any_approver_rule_creation(target, project, params)
      unless approvers_present?
        params.reverse_merge!(rule_type: :any_approver, name: ApprovalRuleLike::ALL_MEMBERS)

        return
      end

      return if project.multiple_approval_rules_available?

      target.approval_rules.any_approver.delete_all
    end

    def approvers_set?
      @params.key?(:user_ids) || @params.key?(:group_ids)
    end

    def approvers_present?
      %i(user_ids group_ids users groups).any? { |key| @params[key].present? }
    end
  end
end
