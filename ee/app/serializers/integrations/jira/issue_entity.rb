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
        jira_user(jira_issue, :reporter)
      end

      expose :assignees do |jira_issue|
        if jira_issue.assignee.present?
          [
            jira_user(jira_issue, :assignee)
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

      # rubocop:disable GitlabSecurity/PublicSend
      def jira_user(jira_issue, user_type)
        {
          name: jira_issue.public_send(user_type).displayName,
          web_url: jira_web_url(jira_issue, user_type),
          avatar_url: jira_issue.public_send(user_type).avatarUrls['48x48']
        }
      end

      def jira_web_url(jira_issue, user_type)
        # There are differences between Jira Cloud and Jira Server URLs and responses.
        # accountId is only available on Jira Cloud.
        # https://community.atlassian.com/t5/Jira-Questions/How-to-find-account-id-on-jira-on-premise/qaq-p/1168652
        if jira_issue.public_send(user_type).try(:accountId)
          "#{base_web_url(jira_issue)}/people/#{jira_issue.public_send(user_type).accountId}"
        else
          "#{base_web_url(jira_issue)}/secure/ViewProfile.jspa?name=#{jira_issue.public_send(user_type).name}"
        end
      end
      # rubocop:enable GitlabSecurity/PublicSend

      def base_web_url(jira_issue)
        site_url = jira_issue.client.options[:site].delete_suffix('/')
        context_path = jira_issue.client.options[:context_path].to_s.delete_prefix('/')

        return site_url if context_path.empty?

        [site_url, context_path].join('/')
      end
    end
  end
end
