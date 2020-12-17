# frozen_string_literal: true

class GroupMergeRequestApprovalSetting < ApplicationRecord
  belongs_to :namespace, inverse_of: :group_merge_request_approval_settings

  default_value_for :allow_author_approval, false

  validates :allow_author_approval, inclusion: { in: [true, false], message: 'must be a boolean value' }

  self.primary_key = :namespace_id
end
