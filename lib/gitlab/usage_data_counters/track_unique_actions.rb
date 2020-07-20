# frozen_string_literal: true

module Gitlab
  module UsageDataCounters
    module TrackUniqueActions
      KEY_EXPIRY_LENGTH = 29.days

      WIKI_ACTION = :wiki_action
      DESIGN_ACTION = :design_action
      PUSH_ACTION = :project_action

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
        }
      }).freeze

      class << self
        def track_action(event_action:, event_target:, author_id:, time: Time.zone.now)
          return unless Gitlab::CurrentSettings.usage_ping_enabled
          return unless valid_target?(event_target)
          return unless valid_action?(event_action)

          transformed_target = transform_target(event_target)
          transformed_action = transform_action(event_action, transformed_target)

          add_event(transformed_action, author_id, time)
        end

        def count_unique_events(event_action:, date_from:, date_to:)
          keys = (date_from.to_date..date_to.to_date).map { |date| key(event_action, date) }

          Gitlab::Redis::SharedState.with do |redis|
            redis.pfcount(*keys)
          end
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

        def key(event_action, date)
          year_day = date.strftime('%G-%j')
          "#{year_day}-{#{event_action}}"
        end

        def add_event(event_action, author_id, date)
          target_key = key(event_action, date)

          Gitlab::Redis::SharedState.with do |redis|
            redis.multi do |multi|
              multi.pfadd(target_key, author_id)
              multi.expire(target_key, KEY_EXPIRY_LENGTH)
            end
          end
        end
      end
    end
  end
end
