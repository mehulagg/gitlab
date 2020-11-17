# frozen_string_literal: true

module Approvable
  # A method related to approvers that is user facing
  # should be moved to VisibleApprovable because
  # of the fact that we use filtered versions of certain methods
  # such as approver_groups and target_project in presenters
  include ::VisibleApprovable

  FORWARDABLE_METHODS = %i{
    approval_needed?
    approved?
    approvals_left
    approvals_required
    can_approve?
    authors_can_approve?
    committers_can_approve?
    approvers_overwritten?
    total_approvals_count
  }.freeze

  delegate(*FORWARDABLE_METHODS, to: :approval_state)

  def approval_feature_available?
    strong_memoize(:approval_feature_available) do
      if project
        project.feature_available?(:merge_request_approvers)
      else
        false
      end
    end
  end

  def approval_state(target_branch: nil)
    approval_state = strong_memoize(:approval_state) do
      Hash.new do |h, key|
        h[key] = ApprovalState.new(self, target_branch: key)
      end
    end

    approval_state[target_branch]
  end

  def approvals_given
    approvals_required - approvals_left
  end

  def approvals_before_merge
    return unless approval_feature_available?

    super
  end

  def approver_ids=(value)
    ::Gitlab::Utils.ensure_array_from_string(value).each do |user_id|
      next if author && user_id == author.id

      approvers.find_or_initialize_by(user_id: user_id, target_id: id)
    end
  end

  def approver_group_ids=(value)
    ::Gitlab::Utils.ensure_array_from_string(value).each do |group_id|
      approver_groups.find_or_initialize_by(group_id: group_id, target_id: id)
    end
  end
end
