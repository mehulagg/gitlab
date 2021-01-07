# frozen_string_literal: true

class GroupMergeRequestApprovalSetting < ApplicationRecord
  belongs_to :group, inverse_of: :group_merge_request_approval_setting

  validates :group, presence: true
  validates :allow_author_approval, inclusion: { in: [true, false], message: 'must be a boolean value' }

  self.primary_key = :group_id
end
