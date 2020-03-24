# frozen_string_literal: true

module Gitlab
  module Subscription
    class MaxSeatsUpdater
      def self.update(group_or_project)
        return if ::Gitlab::Database.read_only?
        return unless Feature.enabled?(:gitlab_com_max_seats_update)
        return unless ::Gitlab::CurrentSettings.should_check_namespace_plan?

        new(group_or_project).update
      end

      def initialize(group_or_project)
        @group_or_project = group_or_project
      end

      def update
        return unless subscription

        seats_in_use = subscription.seats_in_use

        if subscription.max_seats_used < seats_in_use
          subscription.update_column(:max_seats_used, seats_in_use)
        end
      end

      private

      def subscription
        @subscription ||= if @group_or_project.is_a?(Project)
                            @group_or_project.namespace.gitlab_subscription
                          else
                            @group_or_project.gitlab_subscription
                          end
      end
    end
  end
end
