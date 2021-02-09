# frozen_string_literal: true

module EE
  module JiraService
    extend ActiveSupport::Concern

    MAX_URL_LENGTH = 4000

    prepended do
      validates :project_key, presence: true, if: :project_key_required?
      validates :vulnerabilities_issuetype, presence: true, if: :vulnerabilities_enabled
    end

    def jira_vulnerabilities_integration_available?
      feature_enabled = ::Feature.enabled?(:jira_for_vulnerabilities, parent, default_enabled: false)
      feature_available = parent.present? ? parent&.feature_available?(:jira_vulnerabilities_integration) : License.feature_available?(:jira_vulnerabilities_integration)

      feature_enabled && feature_available
    end

    def jira_vulnerabilities_integration_enabled?
      jira_vulnerabilities_integration_available? && vulnerabilities_enabled
    end

    def project_key_required?
      issues_enabled || vulnerabilities_enabled
    end

    def configured_to_create_issues_from_vulnerabilities?
      active? && project_key.present? && vulnerabilities_issuetype.present? && jira_vulnerabilities_integration_enabled?
    end

    def project_issuetype_scheme_ids
      client
        .get(client.options[:rest_base_path] + '/issuetypescheme/project?projectId=' + jira_project_id.to_s)
        .fetch('values', [])
        .map { |schemes| schemes.dig('issueTypeScheme', 'id') }
    end

    def project_issuetype_ids
      query = project_issuetype_scheme_ids.map { |scheme_id| "issueTypeSchemeId=#{scheme_id}" }.join('&')
      client
        .get(client.options[:rest_base_path] + '/issuetypescheme/mapping?' + query)
        .fetch('values', [])
        .map { |schemes| schemes['issueTypeId'] }
    end

    def issue_types
      return [] if jira_project.blank?

      client
        .Issuetype
        .all
        .select { |issue_type| issue_type.id.in?(project_issuetype_ids) }
        .reject { |issue_type| issue_type.subtask }
        .map { |issue_type| { id: issue_type.id, name: issue_type.name, description: issue_type.description } }
    end

    def test(_)
      super.then do |result|
        next result unless result[:success]
        next result unless project.jira_vulnerabilities_integration_enabled?

        result.merge(data: { issuetypes: issue_types })
      end
    end

    def new_issue_url_with_predefined_fields(summary, description)
      escaped_summary = CGI.escape(summary)
      escaped_description = CGI.escape(description)
      "#{url}/secure/CreateIssueDetails!init.jspa?pid=#{jira_project_id}&issuetype=#{vulnerabilities_issuetype}&summary=#{escaped_summary}&description=#{escaped_description}"[0..MAX_URL_LENGTH]
    end

    def create_issue(summary, description)
      return if client_url.blank?

      jira_request do
        issue = client.Issue.build
        issue.save(
          fields: {
            project: { id: jira_project_id },
            issuetype: { id: vulnerabilities_issuetype },
            summary: summary,
            description: description
          }
        )
        issue
      end
    end

    def jira_project_id
      jira_project.id
    end

    def jira_project
      strong_memoize(:jira_project) do
        client_url.present? ? jira_request { client.Project.find(project_key) } : nil
      end
    end
  end
end
