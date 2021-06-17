# frozen_string_literal: true

module RequirementsManagement
  class UpdateRequirementService < BaseService
    def execute(requirement)
      raise Gitlab::Access::AccessDeniedError unless can?(current_user, :update_requirement, project)

      attrs = whitelisted_requirement_params
      requirement.update(attrs)

      sync_with_requirement_issue(attrs, requirement) if requirement.requirement_issue

      create_test_report_for(requirement) if manually_create_test_report?

      requirement
    end

    private

    def manually_create_test_report?
      params[:last_test_report_state].present?
    end

    def create_test_report_for(requirement)
      return unless can?(current_user, :create_requirement_test_report, project)

      TestReport.build_report(requirement: requirement, state: params[:last_test_report_state], author: current_user).save!
    end

    def whitelisted_requirement_params
      params.slice(:title, :description, :state)
    end

    def sync_with_requirement_issue(attrs, requirement)
      return unless requirement.previous_changes.include?(:title) || requirement.previous_changes.include?(:description)

      requirement_issue = requirement.requirement_issue

      ::Issues::UpdateService.new(project: project, current_user: current_user, params: attrs.slice(:title, :description))
          .execute(requirement_issue)
    end
  end
end
