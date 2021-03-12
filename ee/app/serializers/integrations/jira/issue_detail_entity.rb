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
          {
            id: comment['id'],
            body_html: Banzai::Pipeline::JiraGfmPipeline.call(comment['body'], project: project)[:output].to_html,
            created_at: parse_time(comment['created'], comment['author']['timeZone']),
            updated_at: parse_time(comment['updated'], comment['author']['timeZone']),
            author: jira_user(comment['author'])
          }
        end
      end

      private

      # datetime can be in any of the following formats:
      #   "Just now"
      #   "2 days ago 10:05 AM"
      #   "24/Feb/21 7:19 AM"
      #   "08/Jul/20 12:13 PM"
      #   "2021-02-12T16:57:36.175+0000"
      def parse_time(datetime, timezone)
        Time.use_zone(timezone) do
          # Chronic cannot parse a datetime in the format of "24/Feb/21 7:19 AM",
          # we have to remove the AM/PM suffixes.
          datetime.delete_suffix!(' AM')
          datetime.delete_suffix!(' PM')
          Chronic.parse(datetime).utc
        end
      end
    end
  end
end
