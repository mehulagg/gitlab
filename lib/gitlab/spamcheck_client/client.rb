# frozen_string_literal: true
require 'spamcheck'

module Gitlab
  module SpamcheckClient
    class Client
      include ::Spam::SpamConstants

      def initialize(endpoint_url:)
        @endpoint_url = endpoint_url
        @stub = Spamcheck::SpamcheckService::Service::Stub.new(@endpoint_url)
      end

      def is_issue_spam?(target:, user:, context:)
        issue = Spamcheck::Issue.new()
        issue.title = target.spam_title
        issue.description = target.spam_description
        issue.created_at = target.created_at
        issue.updated_at = target.updated_at
        issue.user_in_project = user.authorized_project?(project)
        issue.action = action_to_enum(context[:action])
        issue.user = build_user(user)

        response = @stub.check_for_spam_issue(issue)
        response
      end

      private

      def build_user(user)
        userPB = Spamcheck::User.new()
        userPB.username = user.username
        userPB.org = user.organization
        userPB.created_at = user.created_at

        userPB.emails = user.emails.map do |email| 
          emailPB = Spamcheck::Email.new()
          emailPB.email = email.email
          emailPB.verified = !email.confirmed_at.nil?
        end
        userPB
      end

    end
  end
end