# frozen_string_literal: true

class MergeRequestApprovalSetting < ApplicationRecord
  belongs_to :namespace, inverse_of: :merge_request_approval_settings

  default_value_for :allow_author_approval, true

  validates_inclusion_of :allow_author_approval, in: [true, false]

  scope :find_or_initialize_by_namespace, ->(namespace) {
    find_or_initialize_by(namespace: namespace)
  }
end
