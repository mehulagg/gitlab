# frozen_string_literal: true

# please require all dependencies below:
require_relative 'wrapper' unless defined?(::Gitlab::Redis::Wrapper)

module Gitlab
  module Redis
    class Queues < ::Gitlab::Redis::Wrapper
      SIDEKIQ_NAMESPACE = 'resque:gitlab'
      MAILROOM_NAMESPACE = 'mail_room:gitlab'

      class << self
        def default_url
          'redis://localhost:6381'
        end
      end
    end
  end
end
