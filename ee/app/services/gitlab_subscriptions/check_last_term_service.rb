# frozen_string_literal: true

module GitlabSubscriptions
  class CheckLastTermService
    def initialize(namespace_id:)
      @namespace_id = namespace_id
    end

    def execute
      cached { send_request }
    end

    private

    attr_reader :namespace_id

    def client
      Gitlab::SubscriptionPortal::Client
    end

    def send_request
      response = client.last_term(namespace_id)

      if response[:success]
        response[:last_term]
      else
        nil
      end
    end

    def cache
      Rails.cache
    end

    def cache_key
      "subscription_term:namespace_id:#{namespace_id}"
    end

    def cached
      term = cache.read(cache_key)

      return term unless term.blank?

      cache.fetch(cache_key, force: true, expires_in: 1.day) { yield }
    end
  end
end
