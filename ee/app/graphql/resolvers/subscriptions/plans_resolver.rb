# frozen_string_literal: true

module Resolvers
  module Subscriptions
    class PlansResolver < BaseResolver
      type [::Types::Subscriptions::PlanType], null: true

      description 'Get subscription plan data'

      argument    :plan_tags, [::Types::Subscriptions::PlanTagType], required: false,
                  description: 'Text to echo back.'

      def resolve
        if buy_minutes_feature_available?
          client.plan_data(plan_tags: args[:plan_tags])
        else
          nil
        end
      end

      private

      def buy_minutes_feature_available?
        Feature.enabled?(:new_route_ci_minutes_purchase, default_enabled: :yaml)
      end

      def client
        Gitlab::SubscriptionPortal::Client
      end
    end
  end
end
