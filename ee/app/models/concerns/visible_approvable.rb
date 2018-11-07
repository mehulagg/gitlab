# This module may only be used by presenters or modules
# that include the Approvable concern
module VisibleApprovable
  include ::Gitlab::Utils::StrongMemoize

  def requires_approve?
    # keep until UI changes implemented
    true
  end

  # Users in the list of approvers who have not already approved this MR.
  #
  def approvers_left
    strong_memoize(:approvers_left) do
      User.where(id: all_approvers_including_groups.map(&:id)).where.not(id: approved_by_users.select(:id))
    end
  end

  # The list of approvers from either this MR (if they've been set on the MR) or the
  # target project. Excludes the author if 'self-approval' isn't explicitly
  # enabled on project settings.
  #
  # Before a merge request has been created, author will be nil, so pass the current user
  # on the MR create page.
  #
  # @return [Array<User>]
  def overall_approvers
    if approvers_overwritten?
      code_owners = [] # already persisted into database, no need to recompute
      approvers_relation = approvers
    else
      code_owners = self.code_owners.dup
      approvers_relation = target_project.approvers
    end

    if author && !authors_can_approve?
      approvers_relation = approvers_relation.where.not(user_id: author.id)
    end

    results = code_owners.concat(approvers_relation.includes(:user).map(&:user))
    results.uniq!
    results
  end

  def overall_approver_groups
    approvers_overwritten? ? approver_groups : target_project.approver_groups
  end

  def all_approvers_including_groups
    strong_memoize(:all_approvers_including_groups) do
      approvers = []

      # Approvers not sourced from group level
      approvers << overall_approvers

      approvers << approvers_from_groups

      approvers.flatten
    end
  end

  def approvers_from_groups
    group_approvers = overall_approver_groups.flat_map(&:users)
    group_approvers.delete(author) unless authors_can_approve?
    group_approvers
  end

  def reset_approval_cache!
    approvals(true)
    approved_by_users(true)

    clear_memoization(:approvers_left)
    clear_memoization(:all_approvers_including_groups)
  end
end
