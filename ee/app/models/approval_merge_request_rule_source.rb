# frozen_string_literal: true

# Allow MR rule to lookup its project rule source
class ApprovalMergeRequestRuleSource < NamespaceShard
  belongs_to :approval_merge_request_rule
  belongs_to :approval_project_rule

  validate :validate_project_rule

  private

  def validate_project_rule
    project = approval_merge_request_rule.merge_request.target_project

    unless project.approval_rules.where(id: approval_project_rule_id).exists?
      errors.add(:approval_project_rule, :invalid)
    end
  end
end
