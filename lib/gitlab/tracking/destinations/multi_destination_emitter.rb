# frozen_string_literal: true

module Gitlab
  module Tracking
    module Destinations
      class MultiDestinationEmitter < Base
        extend ::Gitlab::Utils::Override

        DESTINATIONS = [
          Gitlab::Tracking::Destinations::Snowplow.new,
          Gitlab::Tracking::Destinations::ProductAnalytics.new # TODO: Take this out for first iteration
        ].freeze

        override :event
        def event(category, action, label: nil, property: nil, value: nil, context: nil)
          DESTINATIONS.each do |destination|
            destination.event(category, action, label, property, value, context)
          end
        end
      end
    end
  end
end
