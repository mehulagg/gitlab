# frozen_string_literal: true

module Integrations
  module Jira
    class IssueDetailEntity < ::Integrations::Jira::IssueEntity
      expose :description_html do |jira_issue|
        Banzai::Pipeline::GfmPipeline.call(jira_issue.renderedFields['description'], project: nil)[:output].to_html
      end

      expose :state do |jira_issue|
        jira_issue.resolutiondate ? 'closed' : 'opened'
      end

      expose :due_date do |jira_issue|
        jira_issue.duedate&.to_datetime&.utc
      end
    end
  end
end
