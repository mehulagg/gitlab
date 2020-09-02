# frozen_string_literal: true

module Gitlab
  module UsageDataCounters
    module TrackUniqueEvents
      WIKI_ACTION = :wiki_action
      DESIGN_ACTION = :design_action
      PUSH_ACTION = :project_action
      MERGE_REQUEST_ACTION = :merge_request_action

      ACTION_TRANSFORMATIONS = HashWithIndifferentAccess.new({
        wiki: {
          created: WIKI_ACTION,
          updated: WIKI_ACTION,
          destroyed: WIKI_ACTION
        },
        design: {
          created: DESIGN_ACTION,
          updated: DESIGN_ACTION,
          destroyed: DESIGN_ACTION
        },
        project: {
          pushed: PUSH_ACTION
        },
        merge_request: {
          closed: MERGE_REQUEST_ACTION,
          merged: MERGE_REQUEST_ACTION,
          created: MERGE_REQUEST_ACTION,
          commented: MERGE_REQUEST_ACTION
        }
      }).freeze

      class << self
        def track_event(event_action:, event_target:, author_id:, time: Time.zone.now)
          return unless valid_target?(event_target)
          return unless valid_action?(event_action)

          transformed_target = transform_target(event_target)
          transformed_action = transform_action(event_action, transformed_target)

          Gitlab::UsageDataCounters::TrackUniqueActions.track_action(action: transformed_action, author_id: author_id, time: time)
        end

        def count_unique_events(event_action:, date_from:, date_to:)
          Gitlab::UsageDataCounters::TrackUniqueActions.count_unique(action: event_action, date_from: date_from, date_to: date_to)
        end

        private

        def transform_action(event_action, event_target)
          ACTION_TRANSFORMATIONS.dig(event_target, event_action) || event_action
        end

        def transform_target(event_target)
          Event::TARGET_TYPES.key(event_target)
        end

        def valid_target?(target)
          Event::TARGET_TYPES.value?(target)
        end

        def valid_action?(action)
          Event.actions.key?(action)
        end
      end
    end
  end
end
