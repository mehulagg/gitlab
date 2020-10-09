# frozen_string_literal: true

module EE
  module CveRequestHelper
    def request_cve_enabled_for_user?(issue, user)
      can?(user, :admin_project, issue.project) &&
        request_cve_enabled?(issue.project)
    end

    def request_cve_enabled?(project)
      project.visibility_level == ::Gitlab::VisibilityLevel::PUBLIC &&
        request_cve_available?(project) &&
        ProjectSecuritySetting.safe_find_or_create_for(project).cve_id_request_enabled == true
    end

    def request_cve_available?(project)
      ::Gitlab.dev_env_or_com?
    end
  end
end
