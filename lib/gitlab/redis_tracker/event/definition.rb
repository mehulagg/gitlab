# frozen_string_literal: true

module Gitlab
  module RedisTracker
    module Event
      class Definition
        KNOWN_EVENTS_PATH = File.expand_path('../allowed_events/*.yml', __dir__)
        YMLEvent = Struct.new('YMLEvent', :event, :group, :feature_flag)

        def initialize(event:)
          @event = self.class.known_events.find { |e| e.event == event }
        end

        def enabled_for_tracking?
          valid? && feature_enabled?
        end

        def valid?
          @event.present?
        end

        def feature_enabled?
          return false unless valid?
          return true if valid? && @event.feature_flag.blank?

          Feature.enabled?(@event.feature_flag, default_enabled: :yaml)
        end

        class << self
          def known_events
            @known_events ||= load_events(KNOWN_EVENTS_PATH).map do |event|
              YMLEvent.new(event[:name], event[:group], event[:feature_flag])
            end
          end

          def load_events(wildcard)
            Dir[wildcard].each_with_object([]) do |path, events|
              events.push(*load_yaml_from_path(path))
            end
          end

          def load_yaml_from_path(path)
            YAML.safe_load(File.read(path))&.map(&:with_indifferent_access)
          end
        end
      end
    end
  end
end
