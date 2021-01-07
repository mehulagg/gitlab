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

        desc 'Update existing merge request approval setting' do
          detail 'This feature is gated by the :group_merge_request_approval_settings_feature_flag'
          success EE::API::Entities::GroupMergeRequestApprovalSetting
        end
        params do
          optional :allow_author_approval, type: Boolean, desc: 'Allow authors to self-approve merge requests'
        end
        put do
          authorize! :admin_merge_request_approval_settings, user_group

          setting_params = declared_params(include_missing: false)

          response = ::MergeRequestApprovalSettings::UpdateService
            .new(container: user_group, current_user: current_user, params: setting_params).execute

          if response.success?
            present response.payload, with: ::API::Entities::GroupMergeRequestApprovalSetting
          else
            render_api_error!(response.message, :bad_request)
          end
        end
      end
    end
  end
end
