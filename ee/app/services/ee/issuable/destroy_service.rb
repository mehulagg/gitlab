# frozen_string_literal: true

module EE
  module Issuable
    module DestroyService
      extend ::Gitlab::Utils::Override

      private

      override :after_destroy
      def after_destroy(issuable)
        super

        track_usage_ping_epic_destroyed
      end

      override :resource_parent_for
      def resource_parent_for(issuable)
        issuable.is_a?(Epic) ? issuable.resource_parent : super
      end

      def track_usage_ping_epic_destroyed
        ::Gitlab::UsageDataCounters::EpicActivityUniqueCounter.track_epic_destroyed(author: current_user)
      end
    end
  end
end
