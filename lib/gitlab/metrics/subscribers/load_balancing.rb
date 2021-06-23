# frozen_string_literal: true

module Gitlab
  module Metrics
    module Subscribers
      class LoadBalancing < ActiveSupport::Subscriber
        attach_to :load_balancing

        COUNTERS = %i{caught_up_replicas_search_found caught_up_replicas_search_absent}.freeze

        def caught_up_replicas_search(event)
          return unless ::Gitlab::Database::LoadBalancing.enable?

          if event.payload[:found]
            increment(:caught_up_replicas_search_found)
          else
            increment(:caught_up_replicas_search_absent)
          end
        end

        def self.load_balancing_payload
          return {} unless Gitlab::SafeRequestStore.active? && ::Gitlab::Database::LoadBalancing.enable?

          payload = {}
          COUNTERS.each do |counter|
            payload[counter] = Gitlab::SafeRequestStore[counter].to_i
          end
          payload
        end

        private

        def increment(counter)
          current_transaction&.increment("gitlab_transaction_#{counter}_count".to_sym, 1)

          Gitlab::SafeRequestStore[counter] = Gitlab::SafeRequestStore[counter].to_i + 1
        end

        def current_transaction
          ::Gitlab::Metrics::WebTransaction.current || ::Gitlab::Metrics::BackgroundTransaction.current
        end
      end
    end
  end
end

