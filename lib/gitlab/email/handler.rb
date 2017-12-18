require 'gitlab/email/handler/create_merge_request_handler'
require 'gitlab/email/handler/create_note_handler'
require 'gitlab/email/handler/create_issue_handler'
require 'gitlab/email/handler/unsubscribe_handler'

require 'gitlab/email/handler/ee/service_desk_handler'

module Gitlab
  module Email
    module Handler
      HANDLERS = [
        EE::ServiceDeskHandler,
        UnsubscribeHandler,
        CreateNoteHandler,
        CreateMergeRequestHandler,
        CreateIssueHandler
      ].freeze

      def self.for(mail, mail_key)
        HANDLERS.find do |klass|
          handler = klass.new(mail, mail_key)
          break handler if handler.can_handle?
        end
      end
    end
  end
end
