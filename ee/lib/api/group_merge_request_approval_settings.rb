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
      segment ':id/merge_request_approval_settings' do
        desc 'Get all group merge request approval settings' do
          detail 'This feature is gated by the :group_merge_request_approval_settings_feature_flag'
          success EE::API::Entities::GroupMergeRequestApprovalSettings
        end
        get do
          authorize! :read_merge_request_approval_settings, user_group

          present user_group.merge_request_approval_settings,
            with: EE::API::Entities::GroupMergeRequestApprovalSettings
        end
      end
    end
  end
end
