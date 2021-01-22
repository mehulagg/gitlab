# frozen_string_literal: true

module Groups
  module MergeRequestApprovalSettingHelper
    def show_merge_request_approval_setting?(group)
      Feature.enabled?(:group_merge_request_approval_settings_feature_flag) &&
        group.feature_available?(:group_merge_request_approval_settings)
    end
  end
end
