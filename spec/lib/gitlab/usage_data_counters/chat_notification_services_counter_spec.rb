# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::UsageDataCounters::ChatNotificationServicesCounter do
  it_behaves_like 'a redis usage counter', 'Chat Notification', :slack

  it_behaves_like 'a redis usage counter with totals', :chat_notifications, slack: 8
end
