# frozen_string_literal: true
require 'spamcheck'

module Gitlab
  module Spamcheck
    class Client
      include ::Spam::SpamConstants
      DEFAULT_TIMEOUT = 5

      VERDICT_MAPPING = {
        ::Spamcheck::SpamVerdict::Verdict::ALLOW => ALLOW,
        ::Spamcheck::SpamVerdict::Verdict::CONDITIONAL_ALLOW => CONDITIONAL_ALLOW,
        ::Spamcheck::SpamVerdict::Verdict::DISALLOW => DISALLOW,
        ::Spamcheck::SpamVerdict::Verdict::BLOCK => BLOCK_USER
      }.freeze

      def initialize(endpoint_url:)
        # remove the `grpc://` as it's only useful to ensure we're expecting to
        # connect with Spamcheck
        @endpoint_url = endpoint_url.gsub(/^grpc:\/\//, '')
        @stub = ::Spamcheck::SpamcheckService::Stub.new(@endpoint_url,
                                                      :this_channel_is_insecure,
                                                      timeout: DEFAULT_TIMEOUT)
      end

      def issue_spam?(spam_issue:, user:, context: nil)
        issue = build_issue_pb(issue: spam_issue, user: user, context: context)

        response = @stub.check_for_spam_issue(issue)
        verdict = convert_verdict_to_gitlab_constant(response.verdict)
        [verdict, response.error]
      end

      private

      def convert_verdict_to_gitlab_constant(verdict)
        VERDICT_MAPPING.fetch(::Spamcheck::SpamVerdict::Verdict.resolve(verdict), verdict)
      end

      def build_issue_pb(issue:, user:, context: nil )
        issue_pb = ::Spamcheck::Issue.new
        issue_pb.title = issue.spam_title || ''
        issue_pb.description = issue.spam_description || ''
        issue_pb.created_at = convert_to_pb_timestamp(issue.created_at) unless issue.created_at.nil?
        issue_pb.updated_at = convert_to_pb_timestamp(issue.updated_at) unless issue.updated_at.nil?
        issue_pb.user_in_project = user.authorized_project?(issue.project)
        issue_pb.action = action_to_enum(context.fetch(:action)) unless context.nil?
        issue_pb.user = build_user_pb(user)
        issue_pb
      end

      def build_user_pb(user)
        user_pb = ::Spamcheck::User.new
        user_pb.username = user.username
        user_pb.org = user.organization || ''
        user_pb.created_at = convert_to_pb_timestamp(user.created_at)

        primary_email = build_email(user.email, !user.confirmed_at.nil?)

        emails = user.emails.map do |email|
          build_email(email.email, !email.confirmed_at.nil?)
        end

        emails.unshift(primary_email)

        user_pb.emails.replace(emails)
        user_pb
      end

      def build_email(email, verified)
        email_pb = ::Spamcheck::User::Email.new
        email_pb.email = email
        email_pb.verified = verified
        email_pb
      end

      def convert_to_pb_timestamp(ar_timestamp)
        Google::Protobuf::Timestamp.new(seconds: ar_timestamp.to_time.to_i,
                                        nanos: ar_timestamp.to_time.nsec)
      end
    end
  end
end
