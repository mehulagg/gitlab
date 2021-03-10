# frozen_string_literal: true

class GroupMergeRequestApprovalSetting < ApplicationRecord
  self.primary_key = :group_id

  belongs_to :group, inverse_of: :group_merge_request_approval_setting

  validates :group, presence: true
  validates :allow_author_approval, inclusion: { in: [true, false], message: _('must be a boolean value') }
  validates :allow_committer_approval, inclusion: { in: [true, false], message: _('must be a boolean value') }
  validates :allow_overrides_to_approver_list_per_merge_request,
            inclusion: { in: [true, false], message: _('must be a boolean value') }
  validates :retain_approvals_on_push, inclusion: { in: [true, false], message: _('must be a boolean value') }
  validates :require_password_to_approve, inclusion: { in: [true, false], message: _('must be a boolean value') }

  scope :find_or_initialize_by_group, lambda { |group|
    find_or_initialize_by(group: group)
  }
end
