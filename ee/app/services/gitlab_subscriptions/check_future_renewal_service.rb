# frozen_string_literal: true

# Service to determine if the given namespace has a future renewal
# created in the CustomersDot application
#
# If there is a problem querying CustomersDot, it assumes there is no
# future renewal
#
# returns true, false
module GitlabSubscriptions
  class CheckFutureRenewalService
    def initialize(namespace_id:)
      @namespace_id = namespace_id
    end

    def execute
      return false unless Feature.enabled?(:gitlab_subscription_future_renewal, default_enabled: :yaml)

      future_renewal
    end

    private

    attr_reader :namespace_id

    def client
      Gitlab::SubscriptionPortal::Client
    end

    def last_term_request
      response = client.subscription_last_term(namespace_id)

      if response[:success]
        response[:last_term] == false
      else
        nil
      end
    end

    def cache
      Rails.cache
    end

    def cache_key
      "subscription:future_renewal:namespace:#{namespace_id}"
    end

    def future_renewal
      cache.fetch(cache_key, skip_nil: true, expires_in: 1.day) { last_term_request } || false
    end
  end
end
