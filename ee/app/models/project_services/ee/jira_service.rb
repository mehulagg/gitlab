# frozen_string_literal: true

module EE
  module JiraService
    extend ActiveSupport::Concern

    prepended do
      validates :project_key, presence: true, if: :issues_enabled
    end

    def issue_types
      client
        .Issuetype
        .all
        .reject { |issue_type| issue_type.subtask }
        .map { |issue_type| { id: issue_type.id, name: issue_type.name, description: issue_type.description } }
    end

    def test(_)
      super.then do |result|
        next result unless result[:success]
        next result unless project.try(:jira_vulnerabilities_integration_enabled?)

        result.merge(data: { issuetypes: issue_types })
      end
    end
  end
end
