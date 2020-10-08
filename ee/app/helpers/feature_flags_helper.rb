# frozen_string_literal: true

module FeatureFlagsHelper
  include ::API::Helpers::RelatedResourcesHelpers

  def unleash_api_url(project)
    expose_url(api_v4_feature_flags_unleash_path(project_id: project.id))
  end

  def unleash_api_instance_id(project)
    project.feature_flags_client_token
  end

  def feature_flag_issues_links_endpoint(project, feature_flag, user)
    return '' unless Feature.enabled?(:feature_flags_issue_links, project, default_enabled: true) && can?(user, :admin_feature_flags_issue_links, project)

    project_feature_flag_issues_path(project, feature_flag)
  end
end
