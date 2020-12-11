# frozen_string_literal: true

require 'gitlab/email/handler/base_handler'

# handles issue creation emails with these formats:
#   incoming+gitlab-org-gitlab-ce-20-Author_Token12345678-issue-34@incoming.gitlab.com
#   incoming+h5bp-html5-boilerplate-8-1234567890abcdef123456789-merge-request-34@localhost.com
module Gitlab
  module Email
    module Handler
      class CreateNoteAuthorHandler < BaseHandler
        include ReplyProcessing

        attr_reader :issue_iid

        delegate :project, to: :sent_notification, allow_nil: true
        delegate :noteable, to: :sent_notification

        HANDLER_REGEX = /\A#{HANDLER_ACTION_BASE_REGEX}-(?<incoming_email_token>.+)-issue-(?<issue_iid>\d+)\z/.freeze

        def initialize(mail, mail_key)
          super(mail, mail_key)
          binding.pry

          if !mail_key&.include?('/') && (matched = HANDLER_REGEX.match(mail_key.to_s))
            @project_slug         = matched[:project_slug]
            @project_id           = matched[:project_id]&.to_i
            @incoming_email_token = matched[:incoming_email_token]
            @issue_iid            = matched[:issue_iid]&.to_i
          end
        end

        def can_handle?
          incoming_email_token && project_id && issue_iid
        end

        def execute
          binding.pry
          raise SentNotificationNotFoundError unless sent_notification

          sent_notification[:noteable_type] = 'Issue'
          sent_notification[:noteable_id]   = issue.id

          validate_permission!(:create_note)

          raise NoteableNotFoundError unless noteable
          raise EmptyEmailError if message.blank?

          verify_record!(
            record: create_note,
            invalid_exception: InvalidNoteError,
            record_name: 'comment')
        end

        def metrics_event
          :receive_email_create_note
        end

        private

        def issue
          return unless issue_iid

          @issue ||= project&.issues&.find_by_iid(issue_iid)
        end

        def sent_notification
          @sent_notification ||= SentNotification.new(project_id: project_id, recipient_id: author.id)
        end

        def create_note
          sent_notification.create_reply(message)
        end



        # def execute
        #   raise ProjectNotFound unless project
        #   raise IssueNotFound unless issue
        #
        #   validate_permission!(:create_issue)
        #
        #   verify_record!(
        #     record: create_note,
        #     invalid_exception: InvalidIssueError,
        #     record_name: 'issue')
        # end

        # rubocop: disable CodeReuse/ActiveRecord
        def author
          @author ||= User.find_by(incoming_email_token: incoming_email_token)
        end
        # rubocop: enable CodeReuse/ActiveRecord

        # def create_note
        #   Notes::CreateService.new(project, author, reply_params.merge(note: message_including_reply)).execute
        # end

        # def create_issue
        #   Issues::CreateService.new(
        #     project,
        #     author,
        #     title:       mail.subject,
        #     description: message_including_reply
        #   ).execute
        # end
      end
    end
  end
end
