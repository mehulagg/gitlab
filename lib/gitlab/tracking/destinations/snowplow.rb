# frozen_string_literal: true

require 'snowplow-tracker'

module Gitlab
  module Tracking
    module Destinations
      class Snowplow < Base
        extend ::Gitlab::Utils::Override

        override :event
        def event(category, action, label: nil, property: nil, value: nil, context: nil)
          return unless enabled?

          tracker.track_struct_event(category, action, label, property, value, context, (Time.now.to_f * 1000).to_i)
        end

        private

        def enabled?
          Gitlab::CurrentSettings.snowplow_enabled?
        end

        def tracker
          @tracker ||= SnowplowTracker::Tracker.new(
            emitter,
            SnowplowTracker::Subject.new,
            Gitlab::Tracking::SNOWPLOW_NAMESPACE,
            Gitlab::CurrentSettings.snowplow_app_id
          )
        end

        def emitter
          return snowplow_micro_emitter if Gitlab::Tracking.use_snowplow_micro?

          SnowplowTracker::AsyncEmitter.new(
            Gitlab::CurrentSettings.snowplow_collector_hostname,
            protocol: 'https'
          )
        end

        def snowplow_micro_emitter
          SnowplowTracker::AsyncEmitter.new(
            Gitlab::Tracking.snowplow_micro_uri.host,
            port: Gitlab::Tracking.snowplow_micro_uri.port,
            protocol: Gitlab::Tracking.snowplow_micro_uri.scheme
          )
        end
      end
    end
  end
end
