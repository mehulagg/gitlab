# frozen_string_literal: true

module EE
  module JiraService
    extend ActiveSupport::Concern

    prepended do
      validates :project_key, presence: true, if: :issues_enabled
    end

    MAX_URL_LENGTH = 4000

    def new_issue_url_with_predefined_fields(summary, description)
      escaped_summary = CGI.escape(summary)
      escaped_description = CGI.escape(description)
      "#{url}/secure/CreateIssueDetails!init.jspa?pid=#{jira_project_id}&issuetype=#{vulnerabilities_issuetype}&summary=#{escaped_summary}&description=#{escaped_description}"[0..MAX_URL_LENGTH]
    end

    def jira_project_id
      strong_memoize(:jira_project_id) do
        client_url.present? ? jira_request { client.Project.find(project_key).id } : nil
      end
    end
  end
end
