# frozen_string_literal: true

module EE
  module SlackSlashCommandsService
    def chat_responder
      ::Gitlab::Chat::Responder::Slack
    end
  end
end
