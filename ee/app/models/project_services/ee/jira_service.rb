# frozen_string_literal: true

module EE
  module JiraService
    extend ActiveSupport::Concern

    prepended do
      validates :project_key, presence: true, if: :issues_enabled
    end

    def new_issue_url_with_predefined_fields(summary, description)
      return unless project.try(:jira_vulnerabilities_integration_enabled?)

      escaped_summary = CGI.escape(summary)
      escaped_description = CGI.escape(description)
      "#{url}/secure/CreateIssueDetails!init.jspa?pid=#{project_id}&issuetype=#{issue_key}&summary=#{escaped_summary}&description=#{escaped_description}"
    end

    def project_id
      strong_memoize(:project_id) do
        client_url.present? ? jira_request { client.Project.find(project_key).id } : nil
      end
    end
  end
end
