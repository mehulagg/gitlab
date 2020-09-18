# frozen_string_literal: true

module EE
  module CveRequestHelper
    def request_cve_enabled_for_issue_and_user?(issue, user)
      request_cve_enabled?(issue.project) &&
        issue.confidential &&
      issue.confidential &&
        can?(user, :admin_project, issue.project) &&
        request_cve_enabled?(issue.project)
    end

    def request_cve_enabled?(project)
      security_setting = ProjectSecuritySetting.safe_find_or_create_for(project)

      request_cve_available?(project) &&
        security_setting.cve_id_request_enabled == true &&
        project.visibility_level == ::Gitlab::VisibilityLevel::PUBLIC
    end

    def request_cve_available?(project)
      ::Gitlab.dev_env_or_com?
    end
  end
end
