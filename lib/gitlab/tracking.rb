# frozen_string_literal: true

require 'snowplow-tracker'

module Gitlab
  module Tracking
    SNOWPLOW_NAMESPACE = 'gl'

    module ControllerConcern
      extend ActiveSupport::Concern

      protected

      def track_event(action = action_name, **args)
        category = args.delete(:category) || self.class.name
        Gitlab::Tracking.event(category, action.to_s, **args)
      end

      def track_self_describing_event(schema_url, event_data_json, **args)
        Gitlab::Tracking.self_describing_event(schema_url, event_data_json, **args)
      end
    end

    @destination = Gitlab::Tracking::Destinations::Snowplow.new

    class << self
      def enabled?
        Gitlab::CurrentSettings.snowplow_enabled?
      end

      def event(category, action, label: nil, property: nil, value: nil, context: nil)
        @destination.event(category, action, label: label, property: property, value: value, context: context)
      end

      def self_describing_event(schema_url, event_data_json, context: nil)
        @destination.self_describing_event(schema_url, event_data_json, context: nil)
      end

      def snowplow_options(group)
        additional_features = Feature.enabled?(:additional_snowplow_tracking, group)
        {
          namespace: SNOWPLOW_NAMESPACE,
          hostname: Gitlab::CurrentSettings.snowplow_collector_hostname,
          cookie_domain: Gitlab::CurrentSettings.snowplow_cookie_domain,
          app_id: Gitlab::CurrentSettings.snowplow_app_id,
          form_tracking: additional_features,
          link_click_tracking: additional_features
        }.transform_keys! { |key| key.to_s.camelize(:lower).to_sym }
      end
    end
  end
end
