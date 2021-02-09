# frozen_string_literal: true

module API
  class GroupMergeRequestApprovalSettings < ::API::Base
    feature_category :source_code_management

    before do
      authenticate!
      not_found! unless ::Feature.enabled?(:group_merge_request_approval_settings_feature_flag, user_group)
    end

    params do
      requires :id, type: String, desc: 'The ID of a group'
    end
    resource :groups, requirements: ::API::API::NAMESPACE_OR_PROJECT_REQUIREMENTS do
      segment ':id/merge_request_approval_setting' do
        desc 'Get group merge request approval setting' do
          detail 'This feature is gated by the :group_merge_request_approval_settings_feature_flag'
          success ::API::Entities::GroupMergeRequestApprovalSetting
        end
        get do
          authorize! :admin_merge_request_approval_settings, user_group

          present user_group.group_merge_request_approval_setting,
            with: ::API::Entities::GroupMergeRequestApprovalSetting
        end
      end
    end
  end
end
