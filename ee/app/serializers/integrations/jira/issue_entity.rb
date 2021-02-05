# frozen_string_literal: true

module Integrations
  module Jira
    class IssueEntity < Grape::Entity
      expose :project_id do |_jira_issue, options|
        options[:project].id
      end

      expose :title do |jira_issue|
        jira_issue.summary
      end

      expose :created_at do |jira_issue|
        jira_issue.created.to_datetime.utc
      end

      expose :updated_at do |jira_issue|
        jira_issue.updated.to_datetime.utc
      end

      expose :closed_at do |jira_issue|
        jira_issue.resolutiondate&.to_datetime&.utc
      end

      expose :status do |jira_issue|
        jira_issue.status.name
      end

      expose :labels do |jira_issue|
        jira_issue.labels.map do |name|
          {
            name: name,
            color: '#EBECF0',
            text_color: '#283856'

          }
        end
      end

      expose :author do |jira_issue|
        {
          name: jira_issue.reporter.displayName,
          web_url: author_web_url(jira_issue)
        }
      end

      expose :assignees do |jira_issue|
        if jira_issue.assignee.present?
          [
            {
              name: jira_issue.assignee.displayName
            }
          ]
        else
          []
        end
      end

      expose :web_url do |jira_issue|
        "#{base_web_url(jira_issue)}/browse/#{jira_issue.key}"
      end

      expose :references do |jira_issue|
        {
          relative: jira_issue.key
        }
      end

      expose :external_tracker do |_jira_issue|
        'jira'
      end

      private

      def author_web_url(jira_issue)
        # There are differences between Jira Cloud and Jira Server URLs and responses.
        # accountId is only available on Jira Cloud.
        # https://community.atlassian.com/t5/Jira-Questions/How-to-find-account-id-on-jira-on-premise/qaq-p/1168652
        if jira_issue.reporter.try(:accountId)
          "#{base_web_url(jira_issue)}/people/#{jira_issue.reporter.accountId}"
        else
          "#{base_web_url(jira_issue)}/secure/ViewProfile.jspa?name=#{jira_issue.reporter.name}"
        end
      end

      def base_web_url(jira_issue)
        site_url = jira_issue.client.options[:site].delete_suffix('/')
        context_path = jira_issue.client.options[:context_path].to_s.delete_prefix('/')

        return site_url if context_path.empty?

        [site_url, context_path].join('/')
      end
    end
  end
end
