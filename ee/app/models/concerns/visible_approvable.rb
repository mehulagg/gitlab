# frozen_string_literal: true

# This module may only be used by presenters or modules
# that include the Approvable concern
module VisibleApprovable
  include ::Gitlab::Utils::StrongMemoize

  # The list of approvers from either this MR (if they've been set on the MR) or the
  # target project. Excludes the author if 'self-approval' isn't explicitly
  # enabled on project settings.
  #
  # Before a merge request has been created, author will be nil, so pass the current user
  # on the MR create page.
  #
  # @return [Array<User>]
  def overall_approvers(exclude_code_owners: false)
    options = { target: :users }
    options[:code_owner] = false if exclude_code_owners

    approvers = approval_state.filtered_approvers(**options)
    approvers.uniq!
    approvers
  end

  def reset_approval_cache!
    approvals.reset
    approved_by_users.reset
    approval_rules.reset

    clear_memoization(:approval_state)
  end
end
