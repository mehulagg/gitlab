# frozen_string_literal: true
require 'spamcheck'

module Gitlab
  module SpamcheckClient
    class Client
      include ::Spam::SpamConstants
      DEFAULT_TIMEOUT = 5

      VERDICT_MAPPING = {
        Spamcheck::SpamVerdict::Verdict::ALLOW => ALLOW,
        Spamcheck::SpamVerdict::Verdict::CONDITIONAL_ALLOW => CONDITIONAL_ALLOW,
        Spamcheck::SpamVerdict::Verdict::DISALLOW => DISALLOW,
        Spamcheck::SpamVerdict::Verdict::BLOCK => BLOCK_USER
      }.freeze

      def initialize(endpoint_url:)
        @endpoint_url = endpoint_url
        @stub = Spamcheck::SpamcheckService::Stub.new(@endpoint_url,
                                                      :this_channel_is_insecure,
                                                      timeout: DEFAULT_TIMEOUT)
      end

      def issue_spam?(spam_issue:, user:, context: nil)
        issue = Spamcheck::Issue.new
        issue.title = spam_issue.spam_title || ''
        issue.description = spam_issue.spam_description || ''
        issue.created_at = convert_to_pb_timestamp(spam_issue.created_at)
        issue.updated_at = convert_to_pb_timestamp(spam_issue.updated_at)
        issue.user_in_project = user.authorized_project?(spam_issue.project)
        issue.action = action_to_enum(context.fetch(:action)) unless context.nil?
        issue.user = build_user(user)

        response = @stub.check_for_spam_issue(issue)
        verdict = convert_verdict_to_gitlab_constant(response.verdict)
        [verdict, response.error]
      end

      private

      def convert_verdict_to_gitlab_constant(verdict)
        VERDICT_MAPPING.fetch(Spamcheck::SpamVerdict::Verdict.resolve(verdict), verdict)
      end

      def build_user(user)
        user_pb = Spamcheck::User.new
        user_pb.username = user.username
        user_pb.org = user.organization || ''
        user_pb.created_at = convert_to_pb_timestamp(user.created_at)

        emails = user.emails.map do |email|
          email_pb = Spamcheck::Email.new
          email_pb.email = email.email
          email_pb.verified = !email.confirmed_at.nil?
        end

        user_pb.emails.replace(emails)
        user_pb
      end

      def convert_to_pb_timestamp(ar_timestamp)
        Google::Protobuf::Timestamp.new(seconds: ar_timestamp.to_time.to_i,
                                        nanos: ar_timestamp.to_time.nsec)
      end
    end
  end
end
