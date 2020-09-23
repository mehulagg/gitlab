# frozen_string_literal: true

module Gitlab
  module Geo
    module LogCursor
      module Events
        class Event
          include BaseEvent

          def process
            ::Geo::EventWorker.perform_async(event.replicable_name, event.event_name, event.payload)
          end
        end
      end
    end
  end
end
