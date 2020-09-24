# frozen_string_literal: true

module Admin
  module MergeRequestApprovalSettingsHelper
    def show_compliance_merge_request_approval_settings?
      License.feature_available?(:admin_merge_request_approvers_rules)
    end
  end
end
