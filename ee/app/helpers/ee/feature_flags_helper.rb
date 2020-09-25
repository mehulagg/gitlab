# frozen_string_literal: true

module EE
  module FeatureFlagsHelper
    extend ::Gitlab::Utils::Override

    override :feature_flag_issues_links_endpoint
    def feature_flag_issues_links_endpoint(project, feature_flag, user)
      return '' unless can?(user, :admin_feature_flags_issue_links, project)

      project_feature_flag_issues_path(project, feature_flag)
    end
  end
end
