# frozen_string_literal: true

module Integrations
  module Jira
    class IssueDetailEntity < ::Integrations::Jira::IssueEntity
      expose :description_html do |jira_issue|
        Banzai::Pipeline::JiraGfmPipeline
          .call(jira_issue.renderedFields['description'], project: project)[:output].to_html
      end

      expose :state do |jira_issue|
        jira_issue.resolutiondate ? 'closed' : 'opened'
      end

      expose :due_date do |jira_issue|
        jira_issue.duedate&.to_datetime&.utc
      end

      expose :comments do |jira_issue|
        jira_issue.renderedFields['comment']['comments'].map do |comment|
          jira_user(comment['author']).merge(
            note: Banzai::Pipeline::JiraGfmPipeline.call(comment['body'], project: project)[:output].to_html,
            created_at: comment['created'].to_datetime.utc,
            updated_at: comment['updated'].to_datetime.utc
          )
        end
      end
    end
  end
end
