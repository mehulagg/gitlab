# frozen_string_literal: true

module Gitlab
  module Tracking
    module Destinations
      class ProductAnalytics < Base
        extend ::Gitlab::Utils::Override

        override :event
        def event(category, action, label: nil, property: nil, value: nil, context: nil)
          return unless enabled?
          return unless event_allowed?(category, action)

          snowplow.track_struct_event(category, action, label, property, value, context, (Time.now.to_f * 1000).to_i)
        end

        private

        def event_allowed?(category, action)
          # TODO: Think about how this mechanism would work
          category == 'epics' && action == 'promote'
        end

        def enabled?
          Gitlab::CurrentSettings.usage_ping_enabled?
        end

        def project_id
          Gitlab::CurrentSettings.self_monitoring_project_id
        end

        def snowplow
          strong_memoize(:snowplow) do
            SnowplowTracker::Tracker.new(
              SnowplowTracker::AsyncEmitter.new(ProductAnalytics::Tracker::COLLECTOR_URL, protocol: Gitlab.config.gitlab.protocol),
              SnowplowTracker::Subject.new,
              Gitlab::Tracking::SNOWPLOW_NAMESPACE,
              project_id.to_s
            )
          end
        end
      end
    end
  end
end
