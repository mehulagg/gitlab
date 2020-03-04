# frozen_string_literal: true

module Gitlab
  module JiraImport
    ISSUES_MAPPER_CACHE_KEY = 'jira-import/issues-mapper/%{project_id}/issues/%{jira_isssue_id}'
    ALREADY_IMPORTED_ISSUES_CACHE_KEY = 'jira-importer/already-imported/%{project}/%{collection_type}'

    def self.jira_issue_cache_key(project_id, jira_issue_id)
      ISSUES_MAPPER_CACHE_KEY % { project_id: project_id, jira_isssue_id: jira_issue_id }
    end

    def self.already_imported_cache_key(collection_type, project_id)
      ALREADY_IMPORTED_ISSUES_CACHE_KEY % { collection_type: collection_type, project: project_id }
    end
  end
end
