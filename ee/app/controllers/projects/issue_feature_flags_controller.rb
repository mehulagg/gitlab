# frozen_string_literal: true

module Projects
  class IssueFeatureFlagsController < Projects::ApplicationController
    include IssuableLinks

    before_action :authorize_admin_feature_flags_issue_links!

    feature_category :feature_flags

    private

    def create_service
      ::IssueFeatureFlags::CreateService.new(feature_flag, current_user, create_params)
    end

    def list_service
      ::IssueFeatureFlags::ListService.new(issue, current_user)
    end

    def destroy_service
      ::IssueFeatureFlags::DestroyService.new(link, current_user)
    end

    def link
      @link ||= ::FeatureFlagIssue.find(params[:id])
    end

    def issue
      project.issues.find_by_iid(params[:issue_id])
    end
  end
end
