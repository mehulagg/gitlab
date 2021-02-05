# frozen_string_literal: true

class GroupMergeRequestApprovalSetting < ApplicationRecord
  self.primary_key = :group_id

  belongs_to :group, inverse_of: :group_merge_request_approval_setting

  validates :group, presence: true
  validates :allow_author_approval, inclusion: { in: [true, false], message: _('must be a boolean value') }

  scope :find_or_initialize_by_group, ->(group) {
    find_or_initialize_by(group: group)
  }
end
