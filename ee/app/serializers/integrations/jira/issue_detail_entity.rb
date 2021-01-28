# frozen_string_literal: true

module Integrations
  module Jira
    class IssueDetailEntity < IssueEntity
      expose :description do |jira_issue|
        Banzai::Pipeline::GfmPipeline.call(jira_issue.renderedFields['description'], project: nil)[:output].to_html
      end

      # expose :comments do |jira_issue|
      #   jira_issue.renderedFields['comment']['comments'].map do |comment|
      #     {
      #       author: comment['author']['displayName'],
      #       avatar_urls: comment['author']['avatarUrls']['32x32'],
      #       note: Banzai::Pipeline::GfmPipeline.call(comment['body'], project: nil)[:output].to_html,
      #       created_at: comment['created'].to_datetime.utc,
      #       updated_at: comment['updated'].to_datetime.utc
      #     }
      #   end
      # end
    end
  end
end
