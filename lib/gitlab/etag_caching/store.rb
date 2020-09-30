# frozen_string_literal: true

module Gitlab
  module EtagCaching
    class Store
      EXPIRY_TIME = 20.minutes
      CACHE_NAMESPACE = 'etag:'

      def get(key)
        redis.with do |r|
          r.get(key)
        end || fallback_from_shared_state(key)
      end

      def touch(key, only_if_missing: false)
        etag = generate_etag

        redis.with do |r|
          r.set(redis_key(key), etag, ex: EXPIRY_TIME, nx: only_if_missing)
        end

        etag
      end

      private

      def generate_etag
        SecureRandom.hex
      end

      def redis_key(key)
        raise 'Invalid key' if !Rails.env.production? && !Gitlab::EtagCaching::Router.match(key)

        "#{NAMESPACE}#{key}"
      end

      def fallback_from_shared_state(key)
        return nil if Feature.disabled?(:etag_in_redis_cache)

        redis_shared_state.with { |r| r.get(key) }
      end

      def redis
        return redis_shared_state if Feature.disabled?(:etag_in_redis_cache)

        Gitlab::Redis::Cache
      end

      def redis_shared_state
        Gitlab::Redis::SharedState
      end
    end
  end
end
