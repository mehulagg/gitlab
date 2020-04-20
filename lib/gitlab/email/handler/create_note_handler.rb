# frozen_string_literal: true

require 'gitlab/email/handler/base_handler'
require 'gitlab/email/handler/reply_processing'

# handles note/reply creation emails with these formats:
#   incoming+1234567890abcdef1234567890abcdef@incoming.gitlab.com
module Gitlab
  module Email
    module Handler
      class CreateNoteHandler < BaseHandler
        include ReplyProcessing

        delegate :project, to: :sent_notification, allow_nil: true
        delegate :noteable, to: :sent_notification

        def can_handle?
          mail_key =~ /\A\w+\z/
        end

        def execute
          raise SentNotificationNotFoundError unless sent_notification

          validate_permission!(:create_note)

          raise NoteableNotFoundError unless noteable
          raise EmptyEmailError if message.blank?

          note = create_note
          qa_response = note.quick_action_response

          raise CommandsOnlyNoteError, qa_response.warnings if qa_response&.command_failure?

          verify_record!(
            record: note,
            invalid_exception: InvalidNoteError,
            record_name: 'comment')
        end

        def metrics_event
          :receive_email_create_note
        end

        private

        def author
          sent_notification.recipient
        end

        def sent_notification
          @sent_notification ||= SentNotification.for(mail_key)
        end

        def create_note
          sent_notification.create_reply(message)
        end
      end
    end
  end
end
