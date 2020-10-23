# frozen_string_literal: true

module Gitlab
  module UsageDataCounters
    module TrackUniqueEvents
      WIKI_ACTION = :i_source_code_wiki_action
      DESIGN_ACTION = :i_source_code_design_action
      PUSH_ACTION = :i_source_code_project_action
      GIT_WRITE_ACTIONS = [WIKI_ACTION, DESIGN_ACTION, PUSH_ACTION]
      MERGE_REQUEST_ACTION = :i_source_code_merge_request_action

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

          return unless Gitlab::UsageDataCounters::HLLRedisCounter.known_event?(transformed_action.to_s)

          Gitlab::UsageDataCounters::HLLRedisCounter.track_event(author_id, transformed_action.to_s, time)
        end

        def count_unique_events(event_actions:, date_from:, date_to:)
          Gitlab::UsageDataCounters::HLLRedisCounter.unique_events(event_names: Array(event_actions).map(&:to_s), start_date: date_from, end_date: date_to)
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
