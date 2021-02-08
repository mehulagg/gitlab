# frozen_string_literal: true

module Gitlab
  module UsageDataCounters
    module EpicActivityUniqueCounter
      EPIC_CREATED = 'g_product_planning_epic_created'

      class << self
        def track_epic_created_action(author:, time: Time.zone.now)
          track_unique_action(EPIC_CREATED, author, time)
        end

        private

        def track_unique_action(action, author, time)
          return unless Feature.enabled?(:track_epic_activity_actions, default_enabled: true)
          return unless author

          Gitlab::UsageDataCounters::HLLRedisCounter.track_event(action, values: author.id, time: time)
        end
      end
    end
  end
end
