# frozen_string_literal: true

module Gitlab
  module UsageDataCounters
    class GuestPackageEventCounter < BaseCounter
      KNOWN_EVENTS_PATH = File.expand_path('guest_package_events.yml', __dir__)
      KNOWN_EVENTS = YAML.safe_load(File.read(KNOWN_EVENTS_PATH)).freeze
      PREFIX = nil

      class << self
        def redis_key(event)
          require_known_event(event)

          "#{event}_COUNT".upcase
        end

        private

        def counter_key(event)
          "#{event}".to_sym
        end
      end
    end
  end
end
