# frozen_string_literal: true

module EE
  module JiraService
    extend ActiveSupport::Concern

    prepended do
      validates :project_key, presence: true, if: ->(jira_service) { jira_service.issues_enabled || jira_service.vulnerabilities_enabled }
      validates :vulnerabilities_issuetype, presence: true, if: :vulnerabilities_enabled
    end

    def jira_vulnerabilities_integration_enabled?
      project.jira_vulnerabilities_integration_available? && vulnerabilities_enabled
    end
  end
end
