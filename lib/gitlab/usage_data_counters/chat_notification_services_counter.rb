# frozen_string_literal: true

module Gitlab::UsageDataCounters
  class ChatNotificationServicesCounter < BaseCounter
    KNOWN_EVENTS = %w[slack].freeze
    PREFIX = 'chat_notifications'
  end
end
