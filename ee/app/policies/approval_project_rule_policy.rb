# frozen_string_literal: true

class ApprovalProjectRulePolicy < BasePolicy
  delegate { @subject.project }

  condition(:editable) do
    can?(:admin_project, @subject.project)
  end

  rule { editable }.enable :edit_approval_rule

  rule { can?(:read_project) }.enable :read_approval_rule
end
