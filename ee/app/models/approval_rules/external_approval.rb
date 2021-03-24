# frozen_string_literal: true

module ApprovalRules
  class ExternalApproval < ApplicationRecord
    belongs_to :merge_request
    belongs_to :external_approval_rule, class_name: 'ApprovalRules::ExternalApprovalRule'
  end
end
