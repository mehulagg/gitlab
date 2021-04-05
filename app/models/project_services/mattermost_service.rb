# frozen_string_literal: true

class MattermostService < ChatNotificationService
  include SlackMattermost::Notifier

  def title
    'Mattermost notifications'
  end

  def description
    'Receive event notifications in Mattermost'
  end

  def self.to_param
    'mattermost'
  end

  def help
    'This service sends notifications about project events to Mattermost channels. <a href="https://docs.gitlab.com/ee/user/project/integrations/mattermost.html">How do I use this integration?</a>'
  end

  def default_channel_placeholder
    "my-channel"
  end

  def webhook_placeholder
    'http://mattermost.example.com/hooks/'
  end
end
