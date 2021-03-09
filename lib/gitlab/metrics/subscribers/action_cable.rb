# frozen_string_literal: true

module Gitlab
  module Metrics
    module Subscribers
      class ActionCable < ActiveSupport::Subscriber
        attach_to :action_cable

        SINGLE_CLIENT_TRANSMISSION = :single_client_transmission
        TRANSMIT_SUBSCRIPTION_CONFIRMATION = :transmit_subscription_confirmation
        TRANSMIT_SUBSCRIPTION_REJECTION = :transmit_subscription_rejection
        BROADCAST = :broadcast

        def subscription_confirmation(event)
          ::Gitlab::Metrics.count(
            TRANSMIT_SUBSCRIPTION_CONFIRMATION,
            'A subscription by a client was confirmed',
            channel: event.channel
          ).increment
        end

        def subscription_rejection(event)
          transmit_subscription_rejection.increment
        end

        def transmit_to_single_subscriber(event)
          single_client_transmission.increment
        end

        def broadcast_to_all_subscribers(event)
          broadcast.increment
        end

        private

        def single_client_transmission
          @single_client_transmission ||= ::Gitlab::Metrics.count(
            SINGLE_CLIENT_TRANSMISSION,
            'A single message transmitted to a client in channel'
          )
        end

        def transmit_subscription_rejection
          @transmit_subscription_rejection ||= ::Gitlab::Metrics.count(
            TRANSMIT_SUBSCRIPTION_REJECTION,
            'A subscription by a client was rejected'
          )
        end

        def broadcast
          @broadcast ||= ::Gitlab::Metrics.count(
            BROADCAST,
            'A broadcast was emitted'
          )
        end
      end
    end
  end
end
